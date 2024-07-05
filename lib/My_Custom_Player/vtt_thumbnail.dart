import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

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
