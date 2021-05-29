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
      "notifyToken": notifyToken,
      "lastLocation": "",
      "homeLocation": "",
      "AffectedFrom": <String>[],
      "EqHelpRequests": <String>[],
      "ImSafe": <String>[]
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

    final userSnap = await instance.collection('users').doc(user.uid).get();

    final userData = userSnap.data();

    // REHBERE KIMSE EKLENMEMIS
    if (!userData.containsKey('userList')) return null;

    final contactList = userData['userList'];

    List<String> tokens = [];

    for (Map<String, dynamic> contact in contactList) {
      final userData = await getUserDataWithPhoneNumber(contact['phoneNumber']);
      tokens.add(userData['notifyToken']);
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
    if (data == null) {
      return null;
    }
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

  /// Verilen telefon numarasina sahip kisiyi veri tabanindan ceker
  static Future getUserDataWithPhoneNumber(String phoneNumber) async {
    final instance = FirebaseFirestore.instance;

    final userSnapshot = await instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    // bu telefon numarasina sahip biri yok!
    if (userSnapshot.size <= 0) return null;

    final userSnap = userSnapshot.docs[0];
    return userSnap.data();
  }

  static Future<void> feltThisEarthQuake(dynamic earthquakeId) async {
    final user = FirebaseAuth.instance.currentUser;
    final id = user.uid;
    List<dynamic> temp = [];
    temp.add(earthquakeId);
    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"AffectedFrom": FieldValue.arrayUnion(temp)}).then((value) {
      print('Affacted from updated');
    });
  }

  static Future<void> eqHelpRequest(dynamic earthquakeId) async {
    final user = FirebaseAuth.instance.currentUser;
    final id = user.uid;
    List<dynamic> temp = [];
    temp.add(earthquakeId);
    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"EqHelpRequests": FieldValue.arrayUnion(temp)}).then((value) {
      print('EqHelpRequests from updated');
    });
  }

  static Future<void> imSafe(dynamic earthquakeId) async {
    final user = FirebaseAuth.instance.currentUser;
    final id = user.uid;
    List<dynamic> temp = [];
    temp.add(earthquakeId);
    // Call the user's CollectionReference to add a new user
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"ImSafe": FieldValue.arrayUnion(temp)}).then((value) {
      print('imsafe updated');
    });
  }

  static Future<void> SendMessageWithPhoneNumber(String phoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;
  }

  static Future<Map<String, dynamic>> GetDmRoom(String phoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    final instance = FirebaseFirestore.instance;

    DocumentSnapshot ds =
        await instance.collection('users').doc(user.uid).get();

    final userData = ds.data();

    if (!userData.containsKey('dmRooms')) return null;

    final entries = userData['dmRooms'];
    for (String el in entries.keys) {
      if (entries[el]['receiverPhoneNumber'] == phoneNumber) {
        return entries[el];
      }
    }
    return null;
  }

  static Future<CollectionReference> CreateDmRoom(
      String receiverPhoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    final instance = FirebaseFirestore.instance;

    Uuid uuid = Uuid();
    String roomId = uuid.v4();
    CollectionReference cf =
        instance.collection('dmRooms').doc(roomId).collection('messages');

    DocumentReference dr = instance.collection('users').doc(user.uid);

    DocumentSnapshot ds = await dr.get();

    var userData = ds.data();

    if (!userData.containsKey('dmRooms')) userData['dmRooms'] = {};

    userData['dmRooms'][roomId] = {
      'receiverPhoneNumber': receiverPhoneNumber,
      'uid': roomId,
      'userId': user.uid
    };

    await dr.update(userData);

    var receiverUserData =
        await getUserDataWithPhoneNumber(receiverPhoneNumber);

    final receiverUserSnap = await instance
        .collection('users')
        .where('phone', isEqualTo: receiverPhoneNumber)
        .get();

    if (!receiverUserData.containsKey('dmRooms'))
      receiverUserData['dmRooms'] = {};

    receiverUserData['dmRooms'][roomId] = {
      'receiverPhoneNumber': userData['phone'],
      'uid': roomId,
      'userId': receiverUserSnap.docs[0].id
    };

    receiverUserSnap.docs[0].reference.update(receiverUserData);
    return cf;
  }
}
