import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class TamashaVideoPlayer extends StatefulWidget {
  const TamashaVideoPlayer({super.key, required this.title});
  final String title;

  @override
  State<TamashaVideoPlayer> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TamashaVideoPlayer> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    BetterPlayerBufferingConfiguration bufferingConfiguration =
        const BetterPlayerBufferingConfiguration(
      minBufferMs: 30000,
      maxBufferMs: 60000,
      bufferForPlaybackMs: 2500,
      bufferForPlaybackAfterRebufferMs: 5000,
    );

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
      liveStream: false,
      useAsmsSubtitles: false,
      bufferingConfiguration: bufferingConfiguration,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      autoPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        overflowMenuIcon: Icons.settings,
        enableSubtitles: false,
        enableAudioTracks: false,
        enablePlaybackSpeed: false,
        enablePip: true,
        pipMenuIcon: Icons.picture_in_picture,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  double currentPosition = 0.0;

  void _enterPiPMode() async {
    bool isSupported =
        await _betterPlayerController.isPictureInPictureSupported();
    if (isSupported) {
      _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Picture-in-Picture mode is not supported on this device."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_in_picture),
            onPressed: _enterPiPMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                  key: _betterPlayerKey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
