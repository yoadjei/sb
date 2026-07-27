import 'package:flutter/material.dart';

import '../widgets/stadium_scaffold.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StadiumScaffold(
      appBar: AppBar(
        title: const StadiumAppBarTitle('Teams'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Teams',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
