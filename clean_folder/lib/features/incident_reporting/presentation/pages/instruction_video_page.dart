import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:community_safety_app/core/presentation/neo/neo_icon_button.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Plays the "How to use ResQ" guide that ships with the app, in the app's
/// language (Filipino, or English otherwise). It works offline.
class InstructionVideoPage extends StatefulWidget {
  const InstructionVideoPage({super.key});

  static String assetFor(Locale locale) => locale.languageCode == 'fil'
      ? 'assets/videos/how_to_use_fil.mp4'
      : 'assets/videos/how_to_use_en.mp4';

  @override
  State<InstructionVideoPage> createState() => _InstructionVideoPageState();
}

class _InstructionVideoPageState extends State<InstructionVideoPage> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final controller = VideoPlayerController.asset(
      InstructionVideoPage.assetFor(Localizations.localeOf(context)),
    );
    _controller = controller;
    controller.addListener(_onPlayerChanged);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      controller.play();
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  void _onPlayerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    super.dispose();
  }

  bool get _ended {
    final value = _controller!.value;
    return value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration;
  }

  void _togglePlay() {
    final controller = _controller!;
    if (_ended) {
      controller.seekTo(Duration.zero);
      controller.play();
    } else if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  String _clock(Duration d) =>
      '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    // A playback error (a blocked autoplay on the web, a bad file) resets the
    // player, so it counts as a failure rather than an endless spinner.
    final failed = _failed || (controller?.value.hasError ?? false);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  NeoIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.commonClose,
                    tone: NeoIconButtonTone.slate,
                    size: 44,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.dashboardVideoInstructions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: failed
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          l10n.viewerVideoError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ready
                        ? AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: GestureDetector(
                              onTap: _togglePlay,
                              child: VideoPlayer(controller),
                            ),
                          )
                        : const CircularProgressIndicator(),
              ),
            ),
            if (ready && !failed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
                child: Row(
                  children: [
                    NeoIconButton(
                      icon: _ended
                          ? Icons.replay_rounded
                          : (controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded),
                      tooltip: _ended
                          ? l10n.viewerReplay
                          : (controller.value.isPlaying
                              ? l10n.videoPause
                              : l10n.videoPlay),
                      onPressed: _togglePlay,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        colors: const VideoProgressColors(
                          playedColor: AppColors.secondary,
                          bufferedColor: Color(0x3DFFFFFF),
                          backgroundColor: Color(0x1FFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${_clock(controller.value.position)} / ${_clock(controller.value.duration)}',
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
