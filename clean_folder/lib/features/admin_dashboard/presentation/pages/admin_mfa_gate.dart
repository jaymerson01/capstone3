import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:community_safety_app/core/security/totp.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/admin_accounts_remote_data_source.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';

/// Two-step sign-in for the admin portal. After the password, the admin types
/// the 6-digit code from their authenticator app; the first time, they link
/// the app by scanning a QR code. [child] (the panel) shows once that passes.
///
/// The code is checked by the `adminMfa` Cloud Function, not here: a right
/// code opens the server-side admin session the database rules require, so
/// skipping this screen with a stolen password gets no admin access.
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
    setState(() {
      _step = _Step.loading;
      _error = null;
    });
    try {
      String? secret;
      if (!await _accounts.mfaStatus()) {
        try {
          secret = await _accounts.beginMfaSetup();
        } on AdminMfaException catch (e) {
          // Linked in another tab meanwhile: just ask for the code.
          if (e.failure != AdminMfaFailure.setupState) rethrow;
        }
      }
      if (!mounted) return;
      setState(() {
        _secret = secret;
        _step = secret == null ? _Step.verify : _Step.setup;
      });
    } on AdminMfaException catch (e) {
      debugPrint('[AdminMfa] Could not start two-step verification: $e');
      if (!mounted) return;
      setState(() {
        _step = _Step.failed;
        _error = _messageFor(e);
      });
    }
  }

  static const String _unavailableMessage =
      "Couldn't reach the two-step verification server. It may not be deployed yet, "
      'or the connection is down. Try again in a moment.';

  String _messageFor(AdminMfaException e) => switch (e.failure) {
        AdminMfaFailure.wrongCode => 'That code is wrong or expired. Try the newest code in your authenticator app.',
        AdminMfaFailure.lockedOut => 'Too many wrong codes. Wait 15 minutes, then sign in again.',
        AdminMfaFailure.notAllowed => "This account can't use the admin portal.",
        AdminMfaFailure.unavailable => _unavailableMessage,
        AdminMfaFailure.setupState => 'The authenticator setup changed. Scan the new code and try again.',
        AdminMfaFailure.other =>
          "Couldn't check two-step verification${e.message.isEmpty ? '' : ' (${e.message})'}. Try again.",
      };

  Future<void> _submit() async {
    if (_busy) return;
    final code = _code.text.replaceAll(RegExp(r'\s'), '');
    if (code.length != Totp.digits) {
      setState(() => _error = 'Type the ${Totp.digits}-digit code from your authenticator app.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // The server checks the code (and, the first time, links the app and
      // records it in the audit log), then opens the admin session.
      await _accounts.verifyMfaCode(code);
      AdminMfaGate._verifiedUid = _uid;
      if (mounted) setState(() => _step = _Step.passed);
    } on AdminMfaException catch (e) {
      debugPrint('[AdminMfa] $e');
      if (!mounted) return;
      switch (e.failure) {
        case AdminMfaFailure.wrongCode:
          _attempts++;
          setState(() {
            _busy = false;
            _error = _messageFor(e);
          });
          if (_attempts >= AdminMfaGate.maxAttempts) _signOut();
        case AdminMfaFailure.lockedOut || AdminMfaFailure.notAllowed:
          setState(() {
            _busy = false;
            _step = _Step.failed;
            _error = _messageFor(e);
          });
        case AdminMfaFailure.setupState:
          // The pending key was replaced or is gone: start the setup over.
          _busy = false;
          _code.clear();
          await _load();
          if (mounted && _step != _Step.failed) setState(() => _error = _messageFor(e));
        case AdminMfaFailure.unavailable || AdminMfaFailure.other:
          setState(() {
            _busy = false;
            _error = _messageFor(e);
          });
      }
    } catch (e) {
      // Never leave the button doing nothing: show what went wrong.
      debugPrint('[AdminMfa] $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Something went wrong ($e). Try again.';
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
          if (_error == _unavailableMessage) ...[
            const SizedBox(height: 16),
            AdminButton(
              label: 'Try again',
              icon: Icons.refresh,
              expand: true,
              onPressed: _load,
            ),
          ],
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
