import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_chip.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/verification/data/verification_repository.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// The resident sends a photo of their ID so a barangay admin can verify
/// that they live in Moonwalk.
class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.user, this.repository, this.picker});

  final UserEntity user;
  final VerificationRepository? repository;
  final ImagePicker? picker;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late final VerificationRepository _repository = widget.repository ?? VerificationRepository();
  late final Stream<VerificationRequest?> _request = _repository.watchMine(widget.user.id);
  String _idType = 'government_id';
  Uint8List? _photo;
  bool _sending = false;

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    final file = await (widget.picker ?? ImagePicker()).pickImage(source: source, maxWidth: 1200, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    if (bytes.length > VerificationRepository.maxImageBytes) {
      _toast(l10n.idVerifyTooLarge, AppColors.warning);
      return;
    }
    setState(() => _photo = bytes);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await _repository.submit(
        uid: widget.user.id,
        name: widget.user.displayName ?? widget.user.email,
        email: widget.user.email,
        idType: _idType,
        image: _photo!,
      );
      if (mounted) {
        setState(() => _photo = null);
        _toast(l10n.idVerifySent, AppColors.solved);
      }
    } catch (e) {
      debugPrint('[Verification] $e');
      if (mounted) _toast(l10n.idVerifyFailed, AppColors.danger);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.idVerifyTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: StreamBuilder<VerificationRequest?>(
        stream: _request,
        builder: (context, snapshot) {
          final request = snapshot.data;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (widget.user.isVerified)
                    _status(Icons.verified_rounded, AppColors.solved, l10n.idVerifyVerified)
                  else if (request?.isPending == true)
                    _status(Icons.hourglass_top_rounded, AppColors.warning, l10n.idVerifyPending)
                  else ...[
                    if (request != null && !request.isPending)
                      _status(Icons.info_outline_rounded, AppColors.danger, l10n.idVerifyRejected(request.reason ?? '—')),
                    _form(l10n),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _status(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: AppColors.textDark, fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.idVerifyIntro, style: TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Text(l10n.idVerifyIdType, style: TextStyle(color: AppColors.textLight, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (value, label) in [
                ('government_id', l10n.idVerifyGovernmentId),
                ('valid_id', l10n.idVerifyOtherValidId),
              ])
                NeoChip(label: label, selected: _idType == value, onPressed: () => setState(() => _idType = value)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _idType == 'government_id' ? l10n.idVerifyGovernmentExamples : l10n.idVerifyOtherExamples,
            style: TextStyle(color: AppColors.textLight, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(l10n.idVerifyTips, style: TextStyle(color: AppColors.textLight, fontSize: 12.5)),
          const SizedBox(height: 16),
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(_photo!, height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: NeoButton(
                  label: l10n.idVerifyTakePhoto,
                  icon: Icons.photo_camera_rounded,
                  variant: NeoButtonVariant.slate,
                  expand: true,
                  onPressed: _sending ? null : () => _pick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoButton(
                  label: l10n.idVerifyChoosePhoto,
                  icon: Icons.photo_library_rounded,
                  variant: NeoButtonVariant.slate,
                  expand: true,
                  onPressed: _sending ? null : () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          NeoButton(
            key: const Key('verify-submit'),
            label: l10n.idVerifySubmit,
            icon: Icons.send_rounded,
            expand: true,
            onPressed: _photo == null || _sending ? null : _submit,
          ),
        ],
      ),
    );
  }
}
