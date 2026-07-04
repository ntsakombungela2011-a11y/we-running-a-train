import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});
  static Route<dynamic> buildRoute() {
    return buildScreenRoute(screen: const StreakScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puzzle Streak')),
      body: const Center(child: Text('Puzzle Streak (Offline)')),
    );
  }
}
