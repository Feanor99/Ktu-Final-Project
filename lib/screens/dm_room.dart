import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DmRoom extends StatefulWidget {
  final String receiverName;
  final String phoneNumber;
  DmRoom({Key key, this.receiverName, this.phoneNumber}) : super(key: key);

  @override
  _DmRoomState createState() => _DmRoomState();
}

class _DmRoomState extends State<DmRoom> {
  CollectionReference roomRef;
  Map<String, dynamic> room;
  String currentMessage;
  var _controller = TextEditingController();
  var listController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  String userName;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        userName = value.getString('name');
      });
    });
    FirestoreService.GetDmRoom(widget.phoneNumber).then((_room) {
      if (_room != null) {
        roomRef = FirebaseFirestore.instance
            .collection('dmRooms')
            .doc(_room['uid'])
            .collection('messages');
      }
      setState(() {
        room = _room;
      });
    });
  }

  Future sendMessage(String msg) async {
    if (room == null) {
      roomRef = await FirestoreService.CreateDmRoom(widget.phoneNumber);

      final _room = {
        'uid': roomRef.parent.id,
        'receiverPhoneNumber': widget.phoneNumber
      };

      setState(() {
        room = _room;
      });
    }

    var message = {
      'content': msg,
      'createdAt': Timestamp.now(),
      'senderId': user.uid
    };

    await roomRef.add(message);

    // send notification
    await sendNotification(msg);
  }

  Future sendNotification(String message) async {
    var receiverUser =
        await FirestoreService.getUserDataWithPhoneNumber(widget.phoneNumber);

    if (receiverUser == null) return;

    if (!receiverUser.containsKey('notifyToken')) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String senderName;
    if (receiverUser.containsKey('userList')) {
      receiverUser['userList'].forEach((val) {
        if (val['phoneNumber'] == pref.getString('phone'))
          senderName = val['displayName'];
      });
    }

    String token = receiverUser['notifyToken'];
    final String serverToken =
        'AAAAXTCsRjI:APA91bEVJujo9YTgZgB1KwgJJBYjLavDx857efILIh7mkJCw_XZeMu1Qu-gF5tCSwtoshyZTJoo913uQjHcz7DnIovDytqTFPHm7pgmuuveTG_Yye_ngxVMWQ2eW3f8d1UQnLBZXBOCU';

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$senderName: $message',
            'title': 'Okunmamış mesajınız var',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'notification_id': '5',
          },
          'to': token,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final f = new DateFormat('yyyy-MM-dd | H:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: room != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: roomRef
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Bir seyler yanlis gitti');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Mesajlar yukleniyor.");
                        }
                        return new ListView(
                          controller: listController,
                          shrinkWrap: true,
                          reverse: true,
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) {
                            var data = document.data();
                            Timestamp ts = data['createdAt'];
                            DateTime dt = ts.toDate().toLocal();

                            return new Container(
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: data['senderId'] == user.uid
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 6,
                                          bottom: 8),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        constraints: BoxConstraints(
                                          minWidth: 100,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              3,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                data['senderId'] == user.uid
                                                    ? 1
                                                    : 10),
                                            topRight: Radius.circular(
                                                data['senderId'] == user.uid
                                                    ? 10
                                                    : 1),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          color: data['senderId'] == user.uid
                                              ? Colors.green[200]
                                              : Colors.grey[300],
                                        ),
                                        child: Stack(children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            title: Text(
                                              data['content'],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            subtitle: Text(
                                              f
                                                  .format(data['createdAt']
                                                      .toDate()
                                                      .toLocal())
                                                  .toString(),
                                              style: TextStyle(fontSize: 11),
                                              textAlign: TextAlign.right,
                                            ),
                                          )
                                        ]),
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //   right: data['senderId'] == user.uid
                                  //       ? MediaQuery.of(context).size.width - 44
                                  //       : 16,
                                  //   bottom: 9,
                                  //   child: Text(
                                  //     dt
                                  //         .toString()
                                  //         .split(':')
                                  //         .getRange(0, 2)
                                  //         .join(':')
                                  //         .split(' ')[1],
                                  //     style: TextStyle(
                                  //         color: Colors.black87, fontSize: 10),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  : Text("Mesaj yok"),
            ),
          ),
          Container(
              child: Padding(
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      onChanged: (m) => currentMessage = m,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(0),
                        hintText: 'Bir mesaj girin',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      sendMessage(currentMessage);
                      _controller.clear();
                      currentMessage = "";
                    },
                    child: Text("Send"))
              ],
            ),
          ))
        ],
      ),
    );
  }
}
