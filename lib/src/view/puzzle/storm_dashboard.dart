import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class StormDashboardModal extends StatelessWidget {
  const StormDashboardModal({required this.user, super.key});
  final LightUser user;
  static Route<void> buildRoute(LightUser user) {
    return buildScreenRoute(screen: StormDashboardModal(user: user));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storm Dashboard')),
      body: const Center(child: Text('Offline Storm History')),
    );
  }
}
