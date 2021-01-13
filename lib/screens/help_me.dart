import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
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
              'body': 'Yardima ihtiyacim var',
              'title': 'Lutfen bana yardim edin'
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
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: sendAndRetrieveMessage,
            child: Text("YARDIM"),
          ),
        ),
      ),
    );
  }
}
