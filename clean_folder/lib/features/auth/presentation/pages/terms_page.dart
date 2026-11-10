import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// ResQ's Terms and Conditions. Raise [version] when the text changes, and
/// every resident is asked to accept again.
class TermsAndConditions {
  const TermsAndConditions._();

  static const String version = '2026-11';

  static List<(String, String)> sections(AppLocalizations l10n) => [
        (l10n.termsUseTitle, l10n.termsUseBody),
        (l10n.termsAccountTitle, l10n.termsAccountBody),
        (l10n.termsReportsTitle, l10n.termsReportsBody),
        (l10n.termsEmergencyTitle, l10n.termsEmergencyBody),
        (l10n.termsEvidenceTitle, l10n.termsEvidenceBody),
        (l10n.termsPrivacyTitle, l10n.termsPrivacyBody),
        (l10n.termsConductTitle, l10n.termsConductBody),
        (l10n.termsChangesTitle, l10n.termsChangesBody),
      ];
}

/// Remembers who accepted which version: on the phone at once (so it holds
/// offline) and on the resident's profile.
class TermsAcceptanceStore {
  const TermsAcceptanceStore();

  static String _key(String uid) => 'termsAccepted_$uid';

  bool acceptedOnDevice(String uid) {
    try {
      return Hive.box('auth').get(_key(uid)) == TermsAndConditions.version;
    } catch (_) {
      return false;
    }
  }

  Future<void> accept(String uid) async {
    try {
      await Hive.box('auth').put(_key(uid), TermsAndConditions.version);
    } catch (_) {}
    // Not awaited: offline, Firestore sends it once the phone reconnects.
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'termsVersion': TermsAndConditions.version,
      'termsAcceptedAt': FieldValue.serverTimestamp(),
    }).catchError((Object e) => debugPrint('[Terms] Saving acceptance failed: $e'));
  }
}

/// Shows [child] once the resident has accepted the current terms; until then
/// shows the terms with Accept and Decline (which signs out).
class TermsGate extends StatefulWidget {
  const TermsGate({
    super.key,
    required this.user,
    required this.child,
    this.store = const TermsAcceptanceStore(),
    this.onDecline,
  });

  final UserEntity user;
  final Widget child;
  final TermsAcceptanceStore store;
  final VoidCallback? onDecline;

  @override
  State<TermsGate> createState() => _TermsGateState();
}

class _TermsGateState extends State<TermsGate> {
  late bool _accepted = widget.user.acceptedTermsVersion == TermsAndConditions.version ||
      widget.store.acceptedOnDevice(widget.user.id);
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    if (_accepted) return widget.child;
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: LandscapeBackdrop(
          time: isDark ? LandscapeTime.night : LandscapeTime.dusk,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    tone: GlassTone.smoke,
                    blur: true,
                    borderRadius: 28,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.termsTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.termsIntro} ${l10n.termsUpdated}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _TermsSections(l10n: l10n, textColor: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        // Its own Material, so the tap ripple shows on the glass card.
                        Material(
                          type: MaterialType.transparency,
                          child: CheckboxListTile(
                            key: const Key('terms-agree'),
                            value: _agreed,
                            onChanged: (value) => setState(() => _agreed = value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.secondary,
                            side: const BorderSide(color: Colors.white70, width: 1.5),
                            title: Text(
                              l10n.termsAgreeCheckbox,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Custom3dButton(
                          text: l10n.termsAccept,
                          icon: Icons.check_rounded,
                          onPressed: _agreed
                              ? () async {
                                  await widget.store.accept(widget.user.id);
                                  if (mounted) setState(() => _accepted = true);
                                }
                              : null,
                        ),
                        TextButton(
                          onPressed: widget.onDecline ??
                              () => context.read<AuthBloc>().add(const LogoutRequested()),
                          child: Text(
                            l10n.termsDecline,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The terms on their own, opened from Settings.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.termsTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.termsUpdated, style: TextStyle(color: AppColors.textLight, fontSize: 12.5)),
                const SizedBox(height: 8),
                Expanded(child: _TermsSections(l10n: l10n, textColor: AppColors.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsSections extends StatelessWidget {
  const _TermsSections({required this.l10n, required this.textColor});

  final AppLocalizations l10n;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final sections = TermsAndConditions.sections(l10n);
    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final (title, body) = sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. $title',
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(color: textColor.withValues(alpha: 0.88), fontSize: 13.5, height: 1.5),
              ),
            ],
          );
        },
      ),
    );
  }
}
