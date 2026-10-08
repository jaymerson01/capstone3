import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 32,
              offset: const Offset(0, 8),
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
                        color: AppColors.progress.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.videocam_rounded,
                        color: AppColors.progress,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title ?? "Evidence Video Stream",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.open_in_new_rounded,
                          color: AppColors.textLight, size: 18),
                      tooltip: "Open in External Tab",
                      onPressed: () {
                        launchUrl(
                          Uri.parse(_playableUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: AppColors.textLight, size: 20),
                      tooltip: "Close",
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
                                color: AppColors.danger,
                                size: 40,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Unable to stream video in-app",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(widget.videoUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: Icon(Icons.open_in_browser, size: 16),
                                label: Text("Open in External Player", style: TextStyle(fontSize: 12)),
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
                                color: AppColors.progress,
                                strokeWidth: 2.5,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Buffering live evidence stream...",
                                style: TextStyle(
                                  color: AppColors.textLight,
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: AppColors.progress,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.progress,
                          overlayColor: AppColors.progress.withValues(alpha: 0.2),
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
                              size: 26,
                            ),
                            onPressed: _togglePlayPause,
                          ),

                          // Mute/Unmute
                          IconButton(
                            icon: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                            onPressed: _toggleMute,
                          ),

                          // Timestamp Indicator
                          Text(
                            "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Spacer(),

                          // Loop/Replay
                          IconButton(
                            icon: Icon(
                              Icons.replay_rounded,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                            tooltip: "Replay Video",
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
