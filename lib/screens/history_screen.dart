import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Match History'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Match History',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
