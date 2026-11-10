import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_button.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class InAppEvidencePlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const InAppEvidencePlayerDialog({
    super.key,
    required this.videoUrl,
    this.title,
  });

  /// Ensures Cloudinary videos are transcoded and served in universal H.264 MP4 format
  /// so that all web browsers (Edge, Chrome, Safari) and desktop players can decode them
  /// without requiring proprietary HEVC / H.265 codec licenses.
  static String formatPlayableVideoUrl(String rawUrl) {
    if (rawUrl.contains('cloudinary.com') && rawUrl.contains('/video/upload/')) {
      if (!rawUrl.contains('/vc_h264')) {
        return rawUrl.replaceFirst('/video/upload/', '/video/upload/vc_h264,f_mp4/');
      }
    }
    return rawUrl;
  }

  static Future<void> show(
    BuildContext context, {
    required String videoUrl,
    String? title,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => InAppEvidencePlayerDialog(
        videoUrl: videoUrl,
        title: title,
      ),
    );
  }

  @override
  State<InAppEvidencePlayerDialog> createState() =>
      _InAppEvidencePlayerDialogState();
}

class _InAppEvidencePlayerDialogState extends State<InAppEvidencePlayerDialog> {
  late VideoPlayerController _controller;
  late String _playableUrl;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = "";
  bool _isMuted = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _playableUrl = InAppEvidencePlayerDialog.formatPlayableVideoUrl(widget.videoUrl);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(_playableUrl);
      _controller = VideoPlayerController.networkUrl(uri);

      _controller.addListener(() {
        if (!mounted) return;
        setState(() {});
      });

      await _controller.initialize();
      _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        if (_controller.value.position >= _controller.value.duration) {
          _controller.seekTo(Duration.zero);
        }
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  // The player is always dark, like a screen, in the resident app (day or
  // night) and in the admin portal.
  static const Color _soft = Color(0xFFCBD5E1);
  static const Color _line = Color(0x1FFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2433), AppColors.ink],
          ),
          borderRadius: BorderRadius.circular(NeoRadii.card + 2),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(NeoRadii.card + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    const LiveIndicator.ring(
                      size: 36,
                      child: Icon(Icons.videocam_rounded),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title ?? AppLocalizations.of(context).viewerVideoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    NeoIconButton(
                      icon: Icons.open_in_new_rounded,
                      tooltip: AppLocalizations.of(context).viewerOpenExternalTab,
                      tone: NeoIconButtonTone.slate,
                      size: 38,
                      onPressed: () {
                        launchUrl(
                          Uri.parse(_playableUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    NeoIconButton(
                      icon: Icons.close_rounded,
                      tooltip: AppLocalizations.of(context).commonClose,
                      tone: NeoIconButtonTone.slate,
                      size: 38,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Video Stage ──────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  setState(() => _showControls = !_showControls);
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 380),
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_hasError)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.dangerLight,
                                size: 40,
                              ),
                              SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context).viewerVideoError,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: _soft,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              SizedBox(height: 16),
                              NeoButton(
                                label: AppLocalizations.of(context).viewerOpenExternalPlayer,
                                icon: Icons.open_in_browser_rounded,
                                height: 44,
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(widget.videoUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      else if (!_isInitialized)
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.secondary,
                                strokeWidth: 2.5,
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).viewerBuffering,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _soft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio > 0
                                ? _controller.value.aspectRatio
                                : 16 / 9,
                            child: VideoPlayer(_controller),
                          ),
                        ),

                      // Center Play/Pause Indicator on Tap
                      if (_isInitialized && !_controller.value.isPlaying)
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: AppColors.primaryGlowShadow,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Player Controls Bar ──────────────────────────────────────
              if (_isInitialized)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _line, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: AppColors.secondary,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
                          thumbColor: Colors.white,
                          overlayColor: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _controller.value.position.inMilliseconds
                              .toDouble()
                              .clamp(
                                0.0,
                                _controller.value.duration.inMilliseconds.toDouble() > 0
                                    ? _controller.value.duration.inMilliseconds.toDouble()
                                    : 1.0,
                              ),
                          min: 0.0,
                          max: _controller.value.duration.inMilliseconds.toDouble() > 0
                              ? _controller.value.duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            _controller.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),

                      // Buttons Row
                      Row(
                        children: [
                          // Play/Pause Button
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            tooltip: _controller.value.isPlaying
                                ? AppLocalizations.of(context).videoPause
                                : AppLocalizations.of(context).videoPlay,
                            onPressed: _togglePlayPause,
                          ),

                          // Mute/Unmute
                          IconButton(
                            icon: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: _soft,
                              size: 20,
                            ),
                            onPressed: _toggleMute,
                          ),

                          // Timestamp Indicator
                          Text(
                            "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                            style: TextStyle(
                              color: _soft,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),

                          const Spacer(),

                          // Loop/Replay
                          IconButton(
                            icon: Icon(
                              Icons.replay_rounded,
                              color: _soft,
                              size: 20,
                            ),
                            tooltip: AppLocalizations.of(context).viewerReplay,
                            onPressed: () {
                              _controller.seekTo(Duration.zero);
                              _controller.play();
                            },
                          ),
                        ],
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
