import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Music Player'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Music Player',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
