import 'package:eco_minder_flutter_app/em_provision/em_provision.dart';
import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text("Logout"),
            onPressed: () => FireAuthService().signOut(),
          ),
          ElevatedButton(
            child: Text("Add Your EcoMinder"),
            onPressed: () => _toAddEcoMinderScreen(context),
          ),
        ],
      ),
    );
  }

  _toAddEcoMinderScreen(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EMProvisionScreen(),
      withNavBar: false,
    );
  }
}
