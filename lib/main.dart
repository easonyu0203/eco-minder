import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eco_minder_flutter_app/firebase_options.dart';
import 'package:eco_minder_flutter_app/home/home.dart';
import 'package:eco_minder_flutter_app/login/login.dart';
import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:eco_minder_flutter_app/setting/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Minder',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: StreamBuilder(
          stream: FireAuthService().userStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // update user profile
              User user = snapshot.data!;
              FireStoreService()
                  .addUser(user.uid, null, user.displayName, user.email);

              return _buildPersistentTabView(context);
            }
            return const LoginScreen();
          }),
    );
  }

  PersistentTabView _buildPersistentTabView(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      backgroundColor: Color.fromRGBO(255, 240, 215, 1),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      screens: [
        HomeScreen(),
        SettingScreen(),
      ],
      items: [
        _navBarItem(context, FontAwesomeIcons.house, "Home"),
        _navBarItem(context, FontAwesomeIcons.screwdriverWrench, "Setting"),
      ],
    );
  }

  PersistentBottomNavBarItem _navBarItem(
      BuildContext context, IconData icon, String title) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      activeColorPrimary: Theme.of(context).primaryColor.withOpacity(1),
      activeColorSecondary:
          Theme.of(context).colorScheme.secondary.withOpacity(1),
    );
  }
}
