import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp {
  Future<void> addUser(String name, String surname, String phone) async {
    final user = await FirebaseAuth.instance.currentUser;
    final idToken = await user.getIdToken();
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance.collection("users").doc(phone).set({
      "name": name,
      "surname": surname,
      "id": id,
      "phone": phone,
      "idToken": idToken
    }).then((value) {
      print('user added');
    });
  }
}
