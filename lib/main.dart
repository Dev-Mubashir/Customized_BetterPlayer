import 'dart:ui' as ui;
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  List<VTTThumbnail> _thumbnails = [];
  final String vttUrl =
      'https://assets-jpcust.jwpsrv.com/strips/USI7rfYz-120.vtt';

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
    _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(autoPlay: true),
        betterPlayerDataSource: betterPlayerDataSource);

    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final position = event.parameters!['progress'] as Duration?;
        final duration =
            _betterPlayerController.videoPlayerController!.value.duration;

        if (position != null && duration != null) {
          setState(() {
            _currentPosition =
                position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }
    });

    _loadThumbnails();
  }

  double _currentPosition = 0.0;

  void _onSeekBarChanged(double value) {
    setState(() {
      _currentPosition = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(
              controller: _betterPlayerController,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

class CustomSeekBar extends StatefulWidget {
  final double value;
  final ValueChanged<double> onValueChanged;
  final List<VTTThumbnail> cues;

  const CustomSeekBar({
    Key? key,
    required this.value,
    required this.onValueChanged,
    required this.cues,
  }) : super(key: key);

  @override
  State<CustomSeekBar> createState() => _CustomSeekBarState();
}

class _CustomSeekBarState extends State<CustomSeekBar> {
  VTTThumbnail? _currentThumbnail;

  @override
  void initState() {
    super.initState();
    _updateThumbnail(widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateThumbnail(widget.value);
    }
  }

  void _updateThumbnail(double value) {
    final position = Duration(milliseconds: (value * 1000).toInt());
    final thumbnail = _findThumbnailForPosition(position);
    if (thumbnail != _currentThumbnail) {
      setState(() {
        _currentThumbnail = thumbnail;
      });
    }
  }

  VTTThumbnail? _findThumbnailForPosition(Duration position) {
    for (var thumbnail in widget.cues) {
      if (position >= thumbnail.startTime && position <= thumbnail.endTime) {
        return thumbnail;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_currentThumbnail != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CroppedImageWidget(
              thumbnail: _currentThumbnail!,
              width: 100,
              height: 100,
            ),
          ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final offset = box.globalToLocal(details.globalPosition);
            final newValue = offset.dx / box.size.width;
            widget.onValueChanged(newValue);
            _updateThumbnail(newValue);
          },
          child: Container(
            height: 50,
            color: Colors.blueAccent,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: widget.value * MediaQuery.of(context).size.width,
                  height: 10,
                  color: Colors.red,
                ),
                Container(
                  width: 10,
                  height: 10,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VTTThumbnail {
  final Duration startTime;
  final Duration endTime;
  final String imageUrl;
  final Rect cropRect;

  VTTThumbnail({
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    required this.cropRect,
  });
}

Future<List<VTTThumbnail>> parseVTTFileFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception('Failed to load VTT file');
  }

  final vttContent = response.body;
  final lines = LineSplitter.split(vttContent).toList();

  List<VTTThumbnail> thumbnails = [];
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('-->')) {
      final timeRange = lines[i].split(' --> ');
      final startTime = _parseDuration(timeRange[0]);
      final endTime = _parseDuration(timeRange[1]);

      final imageDetails = lines[i + 1].split('#xywh=');
      final imageUrl = imageDetails[0].trim();
      final coordinates = imageDetails[1].split(',').map(int.parse).toList();
      final cropRect = Rect.fromLTWH(
        coordinates[0].toDouble(),
        coordinates[1].toDouble(),
        coordinates[2].toDouble(),
        coordinates[3].toDouble(),
      );

      thumbnails.add(VTTThumbnail(
        startTime: startTime,
        endTime: endTime,
        imageUrl: imageUrl,
        cropRect: cropRect,
      ));
    }
  }

  return thumbnails;
}

Duration _parseDuration(String time) {
  final parts = time.split(':');
  if (parts.length != 2) {
    throw FormatException("Invalid time format, expected mm:ss.sss");
  }

  final secondsParts = parts[1].split('.');
  if (secondsParts.length != 2) {
    throw FormatException("Invalid time format, expected mm:ss.sss");
  }

  final minutes = int.parse(parts[0]);
  final seconds = int.parse(secondsParts[0]);
  final milliseconds = int.parse(secondsParts[1]);

  return Duration(
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

class CroppedImageWidget extends StatefulWidget {
  final VTTThumbnail thumbnail;
  final double width;
  final double height;

  CroppedImageWidget(
      {required this.thumbnail, required this.width, required this.height});

  @override
  _CroppedImageWidgetState createState() => _CroppedImageWidgetState();
}

class _CroppedImageWidgetState extends State<CroppedImageWidget> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      http.Response response = await http.get(Uri.parse(
          "https://assets-jpcust.jwpsrv.com/strips/${widget.thumbnail.imageUrl}"));
      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        ui.Codec codec = await ui.instantiateImageCodec(bytes);
        ui.FrameInfo frameInfo = await codec.getNextFrame();
        setState(() {
          _image = frameInfo.image;
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error loading image: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            width: widget.width,
            height: widget.height,
            child: CustomPaint(
              painter: _CroppedImagePainter(_image!, widget.thumbnail.cropRect,
                  widget.width, widget.height),
            ),
          );
  }
}

class _CroppedImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRect;
  final double width;
  final double height;

  _CroppedImagePainter(this.image, this.cropRect, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      cropRect,
      Rect.fromLTWH(0, 0, width, height),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
