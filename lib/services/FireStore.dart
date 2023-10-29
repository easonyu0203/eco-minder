import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_minder_flutter_app/services/models.dart';

class FireStoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String uid, String? name, String? email) async {
    try {
      MyUser myUser = MyUser(uid: uid, name: name, email: email);
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
    } catch (e) {
      throw e;
    }
  }
}
