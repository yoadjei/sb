import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class ScoreControlScreen extends StatelessWidget {
  const ScoreControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Score Control'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Score Control',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
