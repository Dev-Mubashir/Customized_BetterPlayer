import 'package:betterplayer/Tamasha/Homepage/Movies_data/programs_data_model.dart';
import 'package:betterplayer/Tamasha/Homepage/tamasha_videoplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProgramThumbnail extends StatelessWidget {
  final ProgramDatum programDatum;

  const ProgramThumbnail({Key? key, required this.programDatum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TamashaVideoPlayer(
              title: programDatum.name!,
              videoUrl: programDatum.videoUrl!,
              isLive: programDatum.isLive ?? false,
            ),
          ),
        );
      },
      child: Container(
        // width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(100.0),
        // ),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: programDatum.image!,
                fit: BoxFit.cover,
              ),
            ),

            // Expanded(
            //   child: Image.network(
            //     programDatum.image!,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            // const SizedBox(height: 8.0),
            // Text(
            //   programDatum.name!,
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
          ],
        ),
      ),
    );
  }
}
