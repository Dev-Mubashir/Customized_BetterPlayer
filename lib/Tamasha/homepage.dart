import 'package:betterplayer/Tamasha/tamasha_videoplayer.dart';
import 'package:betterplayer/Tamasha/carousal.dart';
import 'package:betterplayer/Tamasha/colors.dart';
import 'package:betterplayer/Tamasha/json_conversion.dart';
import 'package:betterplayer/Tamasha/thumbnails.dart';
import 'package:flutter/material.dart';

class TamashaHomePage extends StatefulWidget {
  const TamashaHomePage({super.key});

  @override
  _MyTamashaHomePageState createState() => _MyTamashaHomePageState();
}

class _MyTamashaHomePageState extends State<TamashaHomePage> {
  void _navigateToDetailPage() {
    // Navigate to your new page here
    // You can pass the imageUrl as an argument if needed
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Tamasha_videoplayer(
                title: 'Tamasha Video Player',
              )),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(kbgcolor),
        title: const Center(
          child: Text(
            "Tamasha",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: ListView(
        children: [
          GestureDetector(
              onTap: () => _navigateToDetailPage(), child: CarouselExample()),
          FutureBuilder<List<dynamic>>(
            future: loadmovies(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MovieList(movies: snapshot.data!);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Error loading movies');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
