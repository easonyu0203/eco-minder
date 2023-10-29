import 'dart:convert';

import 'package:eco_minder_flutter_app/em_provision/em_provision_state.dart';
import 'package:eco_minder_flutter_app/em_provision/models.dart';
import 'package:eco_minder_flutter_app/share/blink_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class WifiSetupPage extends StatefulWidget {
  final Function(BuildContext context) toNext;
  const WifiSetupPage({super.key, required this.toNext});

  @override
  State<WifiSetupPage> createState() => _WifiSetupPageState();
}

class _WifiSetupPageState extends State<WifiSetupPage> {
  List<WiFi> wifiList = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _findingWifi = false;
  WiFi? loadingWifi;
  int? loadingIdx;

  @override
  void initState() {
    super.initState();
    _findWifiForEM(context.read<EMProvisionState>());
  }

  void _setLoadingWifi(WiFi? wifi, int? idx) {
    if (wifi != null) {
      setState(() {
        loadingWifi = null;
        loadingIdx = null;
      });
    } else {
      setState(() {
        loadingWifi = wifi;
        loadingIdx = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EMProvisionState>(
      builder: (context, state, child) {
        return Column(
          children: [
            Text("Choose the wifi for EcoMinder!"),
            Divider(),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: wifiList.length,
                itemBuilder: (context, index, animation) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: WifiOption(
                      toNext: widget.toNext,
                      wifi: wifiList[index],
                      state: state,
                      setLoadingWifi: (WiFi? wiFi) =>
                          _setLoadingWifi(wiFi, index),
                      isLoading: loadingWifi == wifiList[index],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Visibility(
                visible: _findingWifi,
                child: BlinkText(text: "Scanning Wifi..."),
                replacement: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _findWifiForEM(state),
                  child: Text("Scan for wifi again"),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _findWifiForEM(EMProvisionState state) async {
    setState(() {
      _findingWifi = true;
    });

    Response? response = await state.verifyDeviceNWifiList();
    if (response == null) return;

    // get eco minder id
    state.eco_minder_id = response.payload.id;

    // Find out the differences between the old and the new lists
    final oldWifiList =
        List<WiFi>.from(wifiList); // Making a copy of the old list

    final Set<WiFi> newWifiSet = response.payload.wifi_list!.toSet();
    final Set<WiFi> oldWifiSet = oldWifiList.toSet();

    // Identify WiFis to add and WiFis to remove
    final wifisToAdd = newWifiSet.difference(oldWifiSet).toList();
    final wifisToRemove = oldWifiSet.difference(newWifiSet).toList();

    // Remove WiFis
    for (var wifi in wifisToRemove) {
      int indexToRemove = oldWifiList.indexOf(wifi);
      _listKey.currentState!.removeItem(
        indexToRemove,
        (context, animation) => SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset(0, 0),
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: WifiOption(
            toNext: widget.toNext,
            wifi: wifiList[indexToRemove],
            state: state,
            setLoadingWifi: (WiFi? wifi) => _setLoadingWifi(wifi, 0),
            isLoading: false,
          ),
        ),
      );
      oldWifiList.removeAt(indexToRemove);
    }

    // Add WiFis
    for (var wifi in wifisToAdd) {
      int indexToAdd = response.payload.wifi_list!.indexOf(wifi);
      _listKey.currentState!.insertItem(indexToAdd);
      oldWifiList.insert(indexToAdd, wifi);
    }

    // Update wifiList with the new list
    wifiList = response.payload.wifi_list!;

    if (mounted) {
      setState(() {
        _findingWifi = false;
      });
    }
  }
}

class WifiOption extends StatefulWidget {
  const WifiOption({
    super.key,
    required this.wifi,
    required this.state,
    required this.setLoadingWifi,
    required this.toNext,
    this.isLoading = false,
  });

  final WiFi wifi;
  final EMProvisionState state;
  final Function(WiFi?) setLoadingWifi;
  final bool isLoading;
  final Function(BuildContext context) toNext;

  @override
  State<WifiOption> createState() => _WifiOptionState();
}

class _WifiOptionState extends State<WifiOption> {
  bool isLoading = false; // To control the CupertinoActivityIndicator

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () async {
          widget.setLoadingWifi(widget.wifi);
          setState(() {
            isLoading = true;
          });

          String? userInput = await showCredentialsModal(
              context, widget.wifi.security_protocol);

          bool connected =
              await widget.state.setConnectWifi(widget.wifi, userInput);

          widget.setLoadingWifi(null);

          setState(() {
            isLoading = false;
          });

          widget.toNext(context);
        },
        child: ListTile(
          title: Text(widget.wifi.SSID),
          trailing: isLoading
              ? CupertinoActivityIndicator()
              : Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  Future<String?> showCredentialsModal(
      BuildContext context, String securityProtocol) {
    TextEditingController _controller = TextEditingController();

    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          switch (securityProtocol) {
            case 'WPA2 PSK':
              return CupertinoActionSheet(
                title: Text('Enter WPA Credentials'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text('Save'),
                    onPressed: () {
                      // Handle save action
                      Navigator.pop(context, _controller.text);
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                message: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _controller,
                        placeholder: 'Password',
                      ),
                    ],
                  ),
                ),
              );
            case 'WEP':
              return CupertinoActionSheet(
                title: Text('Enter WEP Credentials'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text('Save'),
                    onPressed: () {
                      // Handle save action
                      Navigator.pop(context, _controller.text);
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                message: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _controller,
                        placeholder: 'Passphrase',
                      ),
                    ],
                  ),
                ),
              );
            default: // For Open or any other protocols
              return CupertinoActionSheet(
                title: Text('Open Network'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text('Connect'),
                    onPressed: () {
                      // Handle connect action
                      Navigator.pop(context);
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              );
          }
        });
  }
}
