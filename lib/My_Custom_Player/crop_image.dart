import 'dart:ui' as ui;
import 'package:betterplayer/My_Custom_Player/vtt_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
