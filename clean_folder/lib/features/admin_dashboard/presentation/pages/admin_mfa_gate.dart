import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:community_safety_app/core/security/totp.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_accounts_remote_data_source.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';

/// Two-step sign-in for the admin portal. After the password, the admin types
/// the 6-digit code from their authenticator app; the first time, they link
/// the app by scanning a QR code. [child] (the panel) shows once that passes.
class AdminMfaGate extends StatefulWidget {
  const AdminMfaGate({
    super.key,
    required this.child,
    this.accounts,
    this.uid,
    this.email,
    this.onSignOut,
  });

  final Widget child;

  /// Defaults to the registered data source and the signed-in admin.
  final AdminAccountsRemoteDataSource? accounts;
  final String? uid;
  final String? email;
  final VoidCallback? onSignOut;

  /// Wrong codes allowed before the admin is signed out.
  static const int maxAttempts = 5;

  // Passing the check lasts until sign-out or a page reload.
  static String? _verifiedUid;

  /// Called on sign-out, so the next sign-in asks for a code again.
  static void endSession() => _verifiedUid = null;

  @override
  State<AdminMfaGate> createState() => _AdminMfaGateState();
}

enum _Step { loading, setup, verify, passed, failed }

class _AdminMfaGateState extends State<AdminMfaGate> {
  late final AdminAccountsRemoteDataSource _accounts = widget.accounts ?? sl<AdminAccountsRemoteDataSource>();
  late final String? _uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
  late final String _email = widget.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
  final TextEditingController _code = TextEditingController();

  _Step _step = _Step.loading;
  String? _secret;
  String? _error;
  bool _busy = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _step = _Step.failed);
      return;
    }
    if (AdminMfaGate._verifiedUid == uid) {
      setState(() => _step = _Step.passed);
      return;
    }
    try {
      final secret = await _accounts.mfaSecret(uid);
      if (!mounted) return;
      setState(() {
        _secret = secret ?? Totp.generateSecret();
        _step = secret == null ? _Step.setup : _Step.verify;
      });
    } on FirebaseException catch (e) {
      debugPrint('[AdminMfa] Could not read the authenticator key: $e');
      if (!mounted) return;
      setState(() {
        _step = _Step.failed;
        _error = e.code == 'permission-denied'
            ? "Two-step verification isn't enabled on the server yet: the updated database rules still need to be deployed."
            : "Couldn't check two-step verification. Check the connection and try again.";
      });
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    final secret = _secret!;
    if (!Totp.verify(secret, _code.text)) {
      _attempts++;
      if (_attempts >= AdminMfaGate.maxAttempts) {
        _signOut();
        return;
      }
      setState(() => _error = 'That code is wrong or expired. Try the newest code in your authenticator app.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_step == _Step.setup) {
        await _accounts.enrollMfa(uid: _uid!, email: _email, secret: secret);
        try {
          await sl<AuditLogRemoteDataSource>().recordLog(
            actionType: 'Security',
            details: 'Turned on two-step verification (authenticator app) for $_email',
            targetId: _uid,
          );
        } catch (e) {
          debugPrint('[AdminMfa] Audit log skipped: $e');
        }
      }
      AdminMfaGate._verifiedUid = _uid;
      if (mounted) setState(() => _step = _Step.passed);
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = "Couldn't save the authenticator link (${e.code}). Try again.";
        });
      }
    }
  }

  void _signOut() {
    AdminMfaGate.endSession();
    (widget.onSignOut ?? () => context.read<AuthBloc>().add(const LogoutRequested()))();
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _Step.passed) return widget.child;

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AdminPanel(
              padding: const EdgeInsets.all(28),
              glow: true,
              child: _step == _Step.loading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(color: AdminColors.cyan)),
                    )
                  : _content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final setup = _step == _Step.setup;
    final failed = _step == _Step.failed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AdminIconTile(icon: Icons.shield_outlined, tone: failed ? AdminTone.red : AdminTone.cyan, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                setup ? 'Set up two-step verification' : 'Two-step verification',
                style: const TextStyle(color: AdminColors.textStrong, fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (failed) ...[
          Text(
            _error ?? 'Sign in again to continue.',
            style: const TextStyle(color: AdminColors.textSoft, fontSize: 13.5, height: 1.5),
          ),
        ] else ...[
          Text(
            setup
                ? 'Admin accounts need a second step. Scan this code with Google Authenticator '
                    '(or Microsoft Authenticator), then type the 6-digit code it shows.'
                : 'Open your authenticator app and type the 6-digit code for ResQ Admin ($_email).',
            style: const TextStyle(color: AdminColors.textSoft, fontSize: 13.5, height: 1.5),
          ),
          if (setup) ...[
            const SizedBox(height: 18),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: QrImageView(
                  data: Totp.otpauthUri(secret: _secret!, account: _email),
                  size: 190,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Can't scan? Add this key in the app instead:",
              textAlign: TextAlign.center,
              style: TextStyle(color: AdminColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 4),
            SelectableText(
              RegExp(r'.{1,4}').allMatches(_secret!).map((m) => m.group(0)).join(' '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AdminColors.cyanText,
                fontSize: 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
          const SizedBox(height: 18),
          TextField(
            key: const Key('mfa-code'),
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(Totp.digits)],
            style: const TextStyle(
              color: AdminColors.textStrong,
              fontSize: 22,
              letterSpacing: 8,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: adminInputDecoration(hint: '6-digit code', icon: Icons.pin_outlined, errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          AdminButton(
            label: setup ? 'Turn on and continue' : 'Verify',
            icon: Icons.verified_user_outlined,
            expand: true,
            busy: _busy,
            onPressed: _submit,
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: _signOut,
          child: const Text('Sign out', style: TextStyle(color: AdminColors.textHint)),
        ),
      ],
    );
  }
}
