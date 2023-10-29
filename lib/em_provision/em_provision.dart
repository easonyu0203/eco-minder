import 'package:eco_minder_flutter_app/em_provision/all_set/all_set.dart';
import 'package:eco_minder_flutter_app/em_provision/connect_em/connect_em.dart';
import 'package:eco_minder_flutter_app/em_provision/em_provision_state.dart';
import 'package:eco_minder_flutter_app/em_provision/wifi_setup/wifi_setup.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';

class EMProvisionScreen extends StatefulWidget {
  const EMProvisionScreen({super.key});

  @override
  State<EMProvisionScreen> createState() => _EMProvisionScreenState();
}

class _EMProvisionScreenState extends State<EMProvisionScreen> {
  final _pageController = PageController();
  late List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      ConnectEMPage(toNext: (context) => _toNextPage()),
      WifiSetupPage(toNext: (context) => _toNextPage()),
      AllSetPage(toNext: (context) => Navigator.pop(context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Setup EcoMinder'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => EMProvisionState(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: _pages,
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  activeDotColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toNextPage() {
    if (_pageController.page! < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
