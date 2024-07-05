import 'package:better_player/better_player.dart';
import 'package:betterplayer/crop_image.dart';
import 'package:betterplayer/vtt_thumbnail.dart';
import 'package:flutter/material.dart';

class Tamasha_videoplayer extends StatefulWidget {
  const Tamasha_videoplayer({super.key, required this.title});
  final String title;

  @override
  State<Tamasha_videoplayer> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Tamasha_videoplayer> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();

  List<VTTThumbnail> _thumbnails = [];
  final String vttUrl =
      'https://assets-jpcust.jwpsrv.com/strips/USI7rfYz-120.vtt';

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
      useAsmsSubtitles: true,
      // asmsTrackNames: ["Low quality", "Not so low quality", "Medium quality"],
      subtitles: [
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: "EN",
          urls: [
            "https://dl.dropboxusercontent.com/s/71nzjo2ux3evxqk/example_subtitles.srt"
          ],
        ),
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: "DE",
          urls: [
            "https://dl.dropboxusercontent.com/s/71nzjo2ux3evxqk/example_subtitles.srt"
          ],
        ),
      ],
      bufferingConfiguration: bufferingConfiguration,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      autoPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        pipMenuIcon: Icons.picture_in_picture,
      ),
      subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
          fontSize: 14,
          fontColor: Colors.white,
          backgroundColor: Colors.black38),
    );

    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );

    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final position = event.parameters!['progress'] as Duration?;
        final duration =
            _betterPlayerController.videoPlayerController!.value.duration;

        if (position != null && duration != null) {
          setState(() {
            currentPosition = position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }
    });

    _loadThumbnails();
  }

  double currentPosition = 0.0;

  void _onSeekBarChanged(double value) {
    setState(() {
      currentPosition = value;
    });

    final duration =
        _betterPlayerController.videoPlayerController!.value.duration!;
    final newPosition =
        Duration(milliseconds: (value * duration.inMilliseconds).toInt());
    _betterPlayerController.seekTo(newPosition);
  }

  Future<void> _loadThumbnails() async {
    final thumbnails = await parseVTTFileFromUrl(vttUrl);
    setState(() {
      _thumbnails = thumbnails;
    });
  }

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
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(
              controller: _betterPlayerController,
              key: _betterPlayerKey,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 120 / 67,
                ),
                itemCount: _thumbnails.length,
                itemBuilder: (context, index) {
                  return CroppedImageWidget(
                    thumbnail: _thumbnails[index],
                    width: _thumbnails[index].cropRect.width,
                    height: _thumbnails[index].cropRect.height,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
