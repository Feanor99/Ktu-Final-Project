import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String name, String surname, String phone) {
    // Call the user's CollectionReference to add a new user
    return users
        .add({'name': name, 'surname': surname, 'phone': phone})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
