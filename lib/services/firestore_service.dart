import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreService {
  static Future<void> addUser(String name, String surname, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    final notifyToken = await FirebaseMessaging().getToken();
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance.collection("users").doc(id).set({
      "name": name,
      "surname": surname,
      "phone": phone,
      "notifyToken": notifyToken
    }).then((value) {
      print('user added');
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

    List<String> TOKENS;

    docs.forEach((element) async {
      String phoneNumber = element['phoneNumber'];
      final userSnap = await instance
          .collection("users")
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      print("*******************************************************");
      print(userSnap.docs);
      if (userSnap.docs.length > 0) {
        final anotherUser = userSnap.docs[0].data();
        final notifyToken = anotherUser['notifyToken'];

        if (notifyToken == "" || notifyToken == null) return print("Token YOK");

        TOKENS.add(notifyToken);
      }
    });

    return TOKENS;
  }
}
