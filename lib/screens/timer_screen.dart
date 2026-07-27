import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Match Timer'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Match Timer',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
