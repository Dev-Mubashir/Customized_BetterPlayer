import 'package:betterplayer/Tamasha/homepage.dart';
import 'package:betterplayer/Tamasha/tamasha_livetvplayer.dart';
import 'package:betterplayer/Tamasha/tamasha_videoplayer.dart';
import 'package:betterplayer/main.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const TamashaHomePage(),
    const Tamasha_liveTvPlayer(
      title: 'Tamasha LiveTV Player',
    ),
    const MyHomePage(title: 'Custom Video Player'),
    // const TamashaVideoPlayer(title: "Tamasha Video Player"),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 143, 143, 143),
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        iconSize: 22, // Adjust icon size to maintain consistency
        selectedFontSize: 9, // Ensure the font size does not change
        unselectedFontSize: 9, // Ensure the font size does not change
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Tamasha Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Live TV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'My Player',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.video_library),
          //   label: 'My Library',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.more_horiz),
          //   label: 'More',
          // ),
        ],
      ),
    );
  }
}
