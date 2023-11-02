import 'dart:async';
import 'dart:convert';

import 'package:eco_minder_flutter_app/em_provision/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// device UUIDs
final BluetoothServiceUUID = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
final BluetoothCharacteristicUUID =
    Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");

class EMProvisionState with ChangeNotifier {
  BluetoothDevice? choosedDevice;
  BluetoothCharacteristic? endpointCharacteristic;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  StreamSubscription? _deviceStateSubscription;

  Stream<bool> get isConnectedStream => _connectionStatusController.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? eco_minder_id;

  Future<bool> setDevice(BluetoothDevice device) async {
    choosedDevice = device;
    var success = await _connectToDevice();
    _listenToDeviceConnectionState();
    await _setupSerivesNCharacteristics();
    notifyListeners();
    return success;
  }

  Future<Response> requestViaBluetooth(Request request) async {
    assert(endpointCharacteristic != null);

    var request_json = jsonEncode(request.toJson());
    List<int> dataToSend = utf8.encode(request_json);
    print("sending: $request_json");
    await endpointCharacteristic!.write(dataToSend);

    Response? response;

    for (var i = 0; i < 20; i++) {
      await Future.delayed(Duration(milliseconds: 1000));

      String responseText = await readFromBluetooth();
      dynamic json_response = jsonDecode(responseText);
      response = Response.fromJson(json_response);
      if (response.setter == Setter.ecoMinder) break;
    }

    assert(response!.setter == Setter.ecoMinder);

    print("getting: ${jsonEncode(response!.toJson())}");

    return response;
  }

  Future<void> sendViaBluetooth(String msg) async {
    assert(endpointCharacteristic != null);
    print("sending: $msg");
    List<int> dataToSend = utf8.encode(msg);
    await endpointCharacteristic!.write(dataToSend);
  }

  Future<String> readFromBluetooth() async {
    var dataRcv = await endpointCharacteristic!.read();
    var data = utf8.decode(dataRcv);
    return data;
  }

  Future<void> disconnectFromDevice() async {
    if (choosedDevice != null) {
      await choosedDevice!.disconnect();
    }
  }

  Future<Response?> verifyDeviceNWifiList() async {
    var request = Request(
        endpoint: Endpoint.verifyDevice,
        payload: Payload(),
        setter: Setter.app);

    Response response = await requestViaBluetooth(request);
    String device_type = response.payload.device_type!;
    String status = response.payload.status!;

    if (device_type == "EcoMinder" && status == "verified") {
      return response;
    } else {
      return null;
    }
  }

  Future<bool> setConnectWifi(WiFi wifi, String? password) async {
    var request = Request(
        endpoint: Endpoint.setConnectWiFi,
        payload: Payload(password: password, SSID: wifi.SSID),
        setter: Setter.app);

    Response response = await requestViaBluetooth(request);

    String status = response.payload.status!;

    return status == "connected";
  }

  Future<bool> _connectToDevice() async {
    if (choosedDevice == null) {
      print('No device chosen');
      _connectionStatusController.add(false);
      return false;
    }

    try {
      await choosedDevice!.connect();
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      _connectionStatusController.add(false);
      return false;
    }
  }

  void _listenToDeviceConnectionState() {
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = choosedDevice!.connectionState.listen(
      (state) {
        if (state == BluetoothConnectionState.connected) {
          _isConnected = true;
          _connectionStatusController.add(true);
        } else {
          _isConnected = false;
          _connectionStatusController.add(false);
        }

        notifyListeners();
      },
    );
  }

  Future<void> _setupSerivesNCharacteristics() async {
    List<BluetoothService> services = await choosedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid == BluetoothServiceUUID) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid == BluetoothCharacteristicUUID) {
            endpointCharacteristic = c;
          }
        }
      }
    }

    assert(endpointCharacteristic != null);
  }

  @override
  void dispose() {
    _connectionStatusController.close();
    _deviceStateSubscription?.cancel();
    super.dispose();
  }
}
