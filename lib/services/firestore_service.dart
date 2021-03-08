import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreService {
  static Future<void> addUser(
      String name, String surname, String phone, String location) async {
    final user = FirebaseAuth.instance.currentUser;
    final notifyToken = await FirebaseMessaging.instance.getToken();
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance.collection("users").doc(id).set({
      "name": name,
      "surname": surname,
      "phone": phone,
      "notifyToken": notifyToken,
      "firstLocaion": location
    }).then((value) {
      print('user added');
    });
  }

  static Future<void> updateUserNotifyIdAndLocation(String location) async {
    final user = FirebaseAuth.instance.currentUser;
    final notifyToken = await FirebaseMessaging.instance.getToken();
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance.collection("users").doc(id).update(
        {"notifyToken": notifyToken, "firstLocaion": location}).then((value) {
      print('user updated');
    });
  }

  static Future<void> updateLastLocation(String location) async {
    final user = FirebaseAuth.instance.currentUser;
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"lastLocation": location}).then((value) {
      print('location updated');
    });
  }

  static Future<List<String>> getNotifyTokensFromUserList(User user) async {
    if (user == null) return null;
    final instance = FirebaseFirestore.instance;
    final docsSnapshot = await instance
        .collection("usersList")
        .where('uid', isEqualTo: user.uid)
        .get();

    final docs = docsSnapshot.docs;

    if (docs.length <= 0 || docs == null)
      return null; // REHBERE KIMSEYI EKLEMEMIS

    List<String> tokens = new List<String>();

    for (QueryDocumentSnapshot element in docs) {
      String phoneNumber = element['phoneNumber'];
      final userSnap = await instance
          .collection("users")
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userSnap.docs.length > 0) {
        final anotherUser = userSnap.docs[0].data();
        final notifyToken = anotherUser['notifyToken'];

        if (notifyToken == "" || notifyToken == null) return null;

        tokens.add(notifyToken);
      }
    }

    return tokens;
  }
}
