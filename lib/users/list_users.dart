import 'package:cloud_firestore/cloud_firestore.dart';

class ListUsers {
  printThemAll() async {
    QuerySnapshot snap =
        await FirebaseFirestore.instance.collection('users').get();

    snap.docs.forEach((document) {
      print(document.data());
    });
  }
}
