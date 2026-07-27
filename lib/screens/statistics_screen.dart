import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Statistics'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Statistics',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
