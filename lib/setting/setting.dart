import 'dart:ffi';

import 'package:eco_minder_flutter_app/em_provision/em_provision.dart';
import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:rxdart/rxdart.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<List<dynamic>> _getCombinedData() async {
    return await Future.wait(
        [FireStoreService().getMyUser(), FireStoreService().getEcoMinder()]);
  }

  Stream<UserNEcoMinder> _streamUserNEcoMinder() {
    return Rx.combineLatest2(
        FireStoreService().streamMyUser(),
        FireStoreService().streamEcoMinder(),
        (myUser, EcoMinder) =>
            UserNEcoMinder(user: myUser!, ecoMinder: EcoMinder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 226, 223),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: _streamUserNEcoMinder(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              UserNEcoMinder userNEcoMinder = snapshot.data as UserNEcoMinder;
              MyUser myUser = userNEcoMinder.user;
              EcoMinder? ecoMinder = userNEcoMinder.ecoMinder;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildEcoMinderSetting(
                    context,
                    ecoMinder,
                  ),
                  SizedBox(height: 15),
                  _buildNotificationSetting(myUser),
                  SizedBox(height: 15),
                  _buildUserSetting(),
                ],
              );
            }),
      ),
    );
  }

  _addEcoMinder(BuildContext context) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EMProvisionScreen(),
      withNavBar: false,
    );
  }

  Widget _buildSetions(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...buttons,
      ],
    );
  }

  Widget _buildUserSetting() {
    return _buildSetions(
      "User Settings",
      [
        SettingButton(
          title: "Logout",
          iconData: FontAwesomeIcons.user,
          onPressed: () => FireAuthService().signOut(),
        ),
      ],
    );
  }

  Widget _buildEcoMinderSetting(BuildContext context, EcoMinder? ecoMinder) {
    bool haveEcoMinder = ecoMinder != null;
    return _buildSetions(
      "EcoMinder Settings",
      [
        ...haveEcoMinder
            ? [
                SettingButton(
                  title: "Mild Mode",
                  iconData: FontAwesomeIcons.dog,
                  onPressed: () =>
                      FireStoreService().setEcoMinderMode(EcoMinderMode.mild),
                  trailingIconData: ecoMinder.mode ==
                          EcoMinderMode.mild.toString().split(".").last
                      ? FontAwesomeIcons.check
                      : null,
                ),
                SettingButton(
                  title: "Alert Mode",
                  iconData: FontAwesomeIcons.personRunning,
                  onPressed: () =>
                      FireStoreService().setEcoMinderMode(EcoMinderMode.alert),
                  trailingIconData: ecoMinder.mode ==
                          EcoMinderMode.alert.toString().split(".").last
                      ? FontAwesomeIcons.check
                      : null,
                )
              ]
            : [
                SettingButton(
                  title: "Add Your EcoMinder!!",
                  iconData: FontAwesomeIcons.pagelines,
                  onPressed: () => _addEcoMinder(context),
                  isPrimary: true,
                ),
              ]
      ],
    );
  }

  Widget _buildNotificationSetting(MyUser myUser) {
    String notificationMode = myUser.notification_mode;
    return _buildSetions(
      "Notification Settings",
      [
        SettingButton(
          title: "No Notification",
          iconData: FontAwesomeIcons.bellSlash,
          onPressed: () =>
              FireStoreService().setNotificationMode(NotificationMode.none),
          trailingIconData: notificationMode ==
                  NotificationMode.none.toString().split(".").last
              ? FontAwesomeIcons.check
              : null,
        ),
        SettingButton(
          title: "Normal Notification",
          iconData: FontAwesomeIcons.bell,
          onPressed: () =>
              FireStoreService().setNotificationMode(NotificationMode.medium),
          trailingIconData: notificationMode ==
                  NotificationMode.medium.toString().split(".").last
              ? FontAwesomeIcons.check
              : null,
        ),
        SettingButton(
          title: "Lot of Notification",
          iconData: FontAwesomeIcons.exclamation,
          onPressed: () =>
              FireStoreService().setNotificationMode(NotificationMode.high),
          trailingIconData: notificationMode ==
                  NotificationMode.high.toString().split(".").last
              ? FontAwesomeIcons.check
              : null,
        ),
      ],
    );
  }
}

class SettingButton extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? trailingIconData;
  const SettingButton({
    super.key,
    required this.title,
    required this.iconData,
    required this.onPressed,
    this.isPrimary = false,
    this.trailingIconData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9)
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Make space between the start and end of the row
            children: [
              Row(
                children: [
                  Icon(iconData, size: 20),
                  SizedBox(width: 10),
                  Text(title, style: TextStyle(fontSize: 16)),
                ],
              ),
              if (trailingIconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(trailingIconData, size: 24),
                )
            ],
          ),
        ),
      ),
    );
  }
}
