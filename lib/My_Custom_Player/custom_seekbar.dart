import 'package:betterplayer/My_Custom_Player/crop_image.dart';
import 'package:betterplayer/My_Custom_Player/vtt_thumbnail.dart';
import 'package:flutter/material.dart';

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
