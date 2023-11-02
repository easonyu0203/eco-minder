import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:eco_minder_flutter_app/services/FireMessage.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FireStoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<MyUser> getMyUser() async {
    User user = FireAuthService().user!;

    var doc = await _firestore.collection('users').doc(user.uid).get();
    MyUser myUser = MyUser.fromJson(doc.data()!);
    return myUser;
  }

  Future<void> setUserToken() async {
    User user = FireAuthService().user!;
    String? token = await FireMessageService().getDeviceToken();
    await _firestore.collection('users').doc(user.uid).set({
      "token": token,
    }, SetOptions(merge: true));
  }

  Future<void> removeEcoMinderFromUser() async {
    User user = FireAuthService().user!;
    await _firestore.collection('users').doc(user.uid).set({
      "eco_minder_id": null,
    }, SetOptions(merge: true));
  }

  Future<EcoMinder?> getEcoMinder() async {
    MyUser myUser = await getMyUser();

    if (myUser.eco_minder_id == null) {
      return null;
    }

    var doc = await _firestore
        .collection('eco_minders')
        .doc(myUser.eco_minder_id)
        .get();
    EcoMinder ecoMinder = EcoMinder.fromJson(doc.data()!);
    return ecoMinder;
  }

  Stream<MyUser?> streamMyUser() {
    User? user = FireAuthService().user;

    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return MyUser.fromJson(snapshot.data()!);
        } else {
          return null;
        }
      },
    );
  }

  Stream<EcoMinder?> streamEcoMinder() {
    return streamMyUser().switchMap(
      (myUser) {
        if (myUser?.eco_minder_id == null) {
          return Stream<EcoMinder?>.value(null);
        }
        return _firestore
            .collection('eco_minders')
            .doc(myUser!.eco_minder_id)
            .snapshots()
            .map(
          (snapshot) {
            if (snapshot.exists) {
              return EcoMinder.fromJson(snapshot.data()!);
            } else {
              return null;
            }
          },
        );
      },
    );
  }

  Future<void> addUser(
      String uid, String? token, String? name, String? email) async {
    try {
      MyUser myUser = MyUser(uid: uid, token: token, name: name, email: email);
      var doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .set(myUser.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }

  Future<void> addEcoMinder(String uid, String eco_minder_id) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({"eco_minder_id": eco_minder_id});
      await _firestore
          .collection("eco_minders")
          .doc(eco_minder_id)
          .set(EcoMinder(
            uid: uid,
            eco_minder_id: eco_minder_id,
            created_at: DateTime.now(),
            name: "Eason's EcoMinder",
          ).toJson());
    } catch (e) {
      throw e;
    }
  }

  Future<void> setEcoMinderMode(EcoMinderMode mode) async {
    MyUser myUser = await getMyUser();
    await _firestore.collection('eco_minders').doc(myUser.eco_minder_id).set({
      "mode": mode.toString().toString().split('.').last,
    }, SetOptions(merge: true));
  }

  Future<void> setNotificationMode(NotificationMode mode) async {
    User user = FireAuthService().user!;
    await _firestore.collection('users').doc(user.uid).set({
      "notification_mode": mode.toString().split('.').last,
    }, SetOptions(merge: true));
  }

  Stream<NumberSensorData> streamIndoorTemp() {
    return _firestore
        .collection('temp_sensor')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((event) => NumberSensorData.fromJson(event.docs[0].data()));
  }

  Stream<NumberSensorData> streamOutdoorTemp() {
    return _firestore
        .collection('outdoor_temp_sensor')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((event) => NumberSensorData.fromJson(event.docs[0].data()));
  }

  Stream<NumberSensorData> streamAirQuality() {
    return _firestore
        .collection('iaq_sensor')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((event) => NumberSensorData.fromJson(event.docs[0].data()));
  }

  Stream<NumberSensorData> streamLightLevel() {
    return _firestore
        .collection('light_sensor')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((event) => NumberSensorData.fromJson(event.docs[0].data()));
  }

  Stream<SensorDatas> streamSensorDatas() {
    return Rx.combineLatest4(
      streamLightLevel(),
      streamIndoorTemp(),
      streamOutdoorTemp(),
      streamAirQuality(),
      (
        NumberSensorData light,
        NumberSensorData indoor,
        NumberSensorData outdoor,
        NumberSensorData air,
      ) =>
          SensorDatas(
        lightLevel: light,
        indoorTemp: indoor,
        outdoorTemp: outdoor,
        airQuality: air,
      ),
    );
  }

  Stream<List<NumberSensorData>> streamRecentIndoorTemps(int count) {
    return _firestore
        .collection('temp_sensor')
        .orderBy('timestamp', descending: true)
        .limit(count)
        .snapshots()
        .map((event) => event.docs
            .map((e) => NumberSensorData.fromJson(e.data()))
            .toList());
  }

  Stream<List<NumberSensorData>> streamRecentOutdoorTemps(int count) {
    return _firestore
        .collection('outdoor_temp_sensor')
        .orderBy('timestamp', descending: true)
        .limit(count)
        .snapshots()
        .map((event) => event.docs
            .map((e) => NumberSensorData.fromJson(e.data()))
            .toList());
  }

  Stream<List<NumberSensorData>> streamRecentAirQualitys(int count) {
    return _firestore
        .collection('iaq_sensor')
        .orderBy('timestamp', descending: true)
        .limit(count)
        .snapshots()
        .map((event) => event.docs
            .map((e) => NumberSensorData.fromJson(e.data()))
            .toList());
  }

  Stream<List<NumberSensorData>> streamRecentLightLevels(int count) {
    return _firestore
        .collection('light_sensor')
        .orderBy('timestamp', descending: true)
        .limit(count)
        .snapshots()
        .map((event) => event.docs
            .map((e) => NumberSensorData.fromJson(e.data()))
            .toList());
  }
}
