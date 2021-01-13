import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HelpMe extends StatefulWidget {
  @override
  _HelpMeState createState() => _HelpMeState();
}

class _HelpMeState extends State<HelpMe> {
  final String serverToken =
      'AAAAXTCsRjI:APA91bEVJujo9YTgZgB1KwgJJBYjLavDx857efILIh7mkJCw_XZeMu1Qu-gF5tCSwtoshyZTJoo913uQjHcz7DnIovDytqTFPHm7pgmuuveTG_Yye_ngxVMWQ2eW3f8d1UQnLBZXBOCU';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final contactTokens =
        await FirestoreService.getNotifyTokensFromUserList(user);
    if (contactTokens.length <= 0 || contactTokens == null)
      return null; // TOKEN YOK

    contactTokens.forEach((_token) async {
      print(_token);
      await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Yardıma ihtiyacım var',
              'title': 'Lütfen bana yardım edin!'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': _token,
          },
        ),
      );
    });

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.red, // page deafult font type
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Yardım İste'),
        ),
        body: Container(
          child: Center(
            child: RaisedButton.icon(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Yardım İste'),
                      content: Text(
                          'Gönder butonuna bastığınızda kişi listenizdekilere bildirim gönderilecektir, onaylıyor musunuz?'),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Gönder"),
                            onPressed: () {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "Yardım Çağrısı Gönderildi",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.black54,
                                  timeInSecForIosWeb: 1,
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                              sendAndRetrieveMessage();
                            })
                      ],
                    );
                  },
                );
              },
              label: Text(
                'Yardım Çağrısı Gönder',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.warning,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
