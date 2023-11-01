import 'package:eco_minder_flutter_app/em_provision/em_provision_state.dart';
import 'package:eco_minder_flutter_app/share/blink_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ConnectEMPage extends StatefulWidget {
  final Function(BuildContext context) toNext;

  const ConnectEMPage({super.key, required this.toNext});

  @override
  _ConnectEMPageState createState() => _ConnectEMPageState();
}

class _ConnectEMPageState extends State<ConnectEMPage> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  int? _connectingIdx;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    if (mounted) {
      setState(() {
        _isScanning = true;
      });
    }

    FlutterBluePlus.scanResults.listen(
      (List<ScanResult> results) {
        var validDevices = results
            .where((scanResult) => scanResult.device.platformName != ""
                // &&
                // scanResult.device.platformName
                //     .toLowerCase()
                //     .contains("ecominder"),
                )
            .map((scanResult) => scanResult.device)
            .toList();

        for (var device in validDevices) {
          if (!_devices.contains(device)) {
            _devices.add(device);
            _listKey.currentState?.insertItem(_devices.length - 1);
          }
        }
      },
    );

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    Future.delayed(Duration(seconds: 4)).then((value) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<EMProvisionState>(context, listen: false);

    return Column(
      children: [
        Text("Choose Your EcoMinder"),
        Divider(),
        Expanded(
          child: _devices.length == 0
              ? const Center(child: Text("No EcoMinder found yet."))
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: _devices.length,
                  itemBuilder: (context, index, animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(
                          begin: Offset(1, 0),
                          end: Offset(0, 0),
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: Card(
                        elevation: 3.0,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: InkWell(
                          onTap: () {
                            state.setDevice(_devices[index]).then(
                                  (success) => widget.toNext(context),
                                );

                            if (mounted) {
                              setState(() {
                                _connectingIdx = index;
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(_devices[index].platformName),
                            trailing: _connectingIdx == index
                                ? CupertinoActivityIndicator()
                                : Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Visibility(
            visible: _isScanning,
            child: BlinkText(text: "Scanning EcoMinder..."),
            replacement: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: _startScanning,
              child: Text("Scan again"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    FlutterBluePlus.stopScan();
  }
}
