import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/models/notification_modal.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  static Future<void> addUser(String name, String surname, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    final notifyToken = await FirebaseMessaging.instance.getToken();
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

  static Future<void> addUserPhoneNumber(dynamic phone) async {
    List<dynamic> temp = [];
    temp.add(phone);
    return FirebaseFirestore.instance
        .collection("allPhoneNumbers")
        .doc('PhoneNoList')
        .update(({"data": FieldValue.arrayUnion(temp)}));
  }

  static Future<void> updateUserNotifyId() async {
    final user = FirebaseAuth.instance.currentUser;
    final notifyToken = await FirebaseMessaging.instance.getToken();
    final id = user.uid;

    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"notifyToken": notifyToken}).then((value) {
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

  static Future<List<dynamic>> getAllUserPhone() async {
    final instance = FirebaseFirestore.instance;
    final docsSnapshot =
        await instance.collection("allPhoneNumbers").doc("PhoneNoList").get();

    final docs = docsSnapshot.data();

    return docs["data"];
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

    List<String> tokens = [];

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

  static Future<void> setNotificationToDb(
      String senderId, String receiverToken, Map<String, String> data) async {
    final instance = FirebaseFirestore.instance;

    final userSnapshot = await instance
        .collection('users')
        .where('notifyToken', isEqualTo: receiverToken)
        .get();
    final receiverId = userSnapshot.docs[0].id;

    CollectionReference allNotificationRef =
        instance.collection('allNotifications');

    DocumentReference docRef = allNotificationRef.doc(receiverId);
    DocumentSnapshot docSnap = await allNotificationRef.doc(receiverId).get();
    var uuid = Uuid();

    final fbData = {
      'id': uuid.v4(),
      'receiverId': receiverId,
      'senderId': senderId,
      'date': DateTime.now(),
      ...data
    };

    if (docSnap.exists) {
      docRef.update({
        'notify': FieldValue.arrayUnion([fbData])
      });
    } else {
      docRef.set({
        'notify': [fbData]
      });
    }
  }

  static Future<List<NotificationModel>> getUserNotifications() async {
    final instance = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    DocumentReference notifyReferance =
        instance.collection('allNotifications').doc(user.uid);

    final notifySnapshot = await notifyReferance.get();

    dynamic data = notifySnapshot.data();
    data = data['notify']; // this !MUST! return notify list of the user

    List<NotificationModel> models = [];

    for (var model in data) {
      DocumentReference userRef =
          instance.collection('users').doc(model['senderId']);

      final userSnap = await userRef.get();

      model['senderName'] =
          userSnap.data()['name'] + ' ' + userSnap.data()['surname'];

      NotificationModel myModel = NotificationModel.fromJson(model);
      models.add(myModel);
    }
    return models;
  }

  static Future removeUserNotifiation(String id) async {
    final instance = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    DocumentReference notifyReferance =
        instance.collection('allNotifications').doc(user.uid);

    final notifySnapshot = await notifyReferance.get();

    dynamic data = notifySnapshot.data();
    data = data['notify']; // this !MUST! return notify list of the user

    List<Map> newdata = [];
    data.forEach((element) => {
          if (element['id'] != id) {newdata.add(element)}
        });
    print(data);
    print(newdata);
    await instance
        .collection("allNotifications")
        .doc(user.uid)
        .set({'notify': newdata});
  }
}
