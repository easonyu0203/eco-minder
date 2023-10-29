import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> _handleLogin(Function loginMethod) async {
    setState(() {
      isLoading = true;
    });
    await loginMethod();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: const [
                Text(
                  "Ease Note",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Icon(
                  FontAwesomeIcons.pagelines,
                  size: 150,
                ),
              ],
            ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LoginButton(
                    icon: FontAwesomeIcons.userNinja,
                    text: 'Continue as Guest',
                    loginMethod: () =>
                        _handleLogin(FireAuthService().anonLogin),
                  ),
                  const SizedBox(height: 12),
                  LoginButton(
                    icon: FontAwesomeIcons.google,
                    text: 'Sign in with Google',
                    loginMethod: () =>
                        _handleLogin(FireAuthService().googleLogin),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() loginMethod;

  const LoginButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.loginMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 25,
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(24)),
        onPressed: loginMethod,
        label: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
