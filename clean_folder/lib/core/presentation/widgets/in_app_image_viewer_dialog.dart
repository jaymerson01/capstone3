import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class InAppImageViewerDialog extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const InAppImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? title,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) => InAppImageViewerDialog(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  @override
  State<InAppImageViewerDialog> createState() => _InAppImageViewerDialogState();
}

class _InAppImageViewerDialogState extends State<InAppImageViewerDialog> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              blurRadius: 36,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Bar ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title ?? AppLocalizations.of(context).viewerPhotoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Reset Zoom Button
                    IconButton(
                      icon: Icon(Icons.zoom_out_map_rounded,
                          color: AppColors.textLight, size: 20),
                      tooltip: AppLocalizations.of(context).viewerResetZoom,
                      onPressed: _resetZoom,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    SizedBox(width: 4),
                    // Open External Button
                    IconButton(
                      icon: Icon(Icons.open_in_new_rounded,
                          color: AppColors.textLight, size: 18),
                      tooltip: AppLocalizations.of(context).viewerOpenFullImage,
                      onPressed: () {
                        launchUrl(
                          Uri.parse(widget.imageUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    SizedBox(width: 4),
                    // Close Button
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.textLight, size: 20),
                      tooltip: AppLocalizations.of(context).commonClose,
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),

              // ── Image Stage ──────────────────────────────────────────────
              Flexible(
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.8,
                    maxScale: 4.5,
                    clipBehavior: Clip.none,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded,
                                color: AppColors.danger, size: 48),
                            SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).viewerImageError,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                launchUrl(Uri.parse(widget.imageUrl),
                                    mode: LaunchMode.externalApplication);
                              },
                              icon: Icon(Icons.open_in_browser, size: 16),
                              label: Text(AppLocalizations.of(context).viewerOpenExternalTab),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Footer Hint ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pinch_rounded, size: 14, color: AppColors.textLight),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).viewerZoomHint,
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
