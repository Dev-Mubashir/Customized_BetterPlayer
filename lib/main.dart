import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

import 'crop_image.dart';
import 'vtt_thumbnail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      minBufferMs: 20000,
      maxBufferMs: 50000,
      bufferForPlaybackMs: 2500,
      bufferForPlaybackAfterRebufferMs: 5000,
    );

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      bufferingConfiguration: bufferingConfiguration,
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: true,
          pipMenuIcon: Icons.picture_in_picture,
        ),
      ),
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
