import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_app/services/get_location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HelpMe extends StatefulWidget {
  @override
  _HelpMeState createState() => _HelpMeState();
}

class _HelpMeState extends State<HelpMe> {
  final String serverToken =
      'AAAAXTCsRjI:APA91bEVJujo9YTgZgB1KwgJJBYjLavDx857efILIh7mkJCw_XZeMu1Qu-gF5tCSwtoshyZTJoo913uQjHcz7DnIovDytqTFPHm7pgmuuveTG_Yye_ngxVMWQ2eW3f8d1UQnLBZXBOCU';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String latitude, longitude;

  void initState() {
    super.initState();
    updateLocation();
  }

  updateLocation() async {
    var location = await GetLocation.checkPermissionThenGetLocation();
    latitude = location.latitude.toString();
    longitude = location.longitude.toString();
    String userLocation = latitude + ", " + longitude;
    FirestoreService.updateLastLocation(userLocation);
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final contactTokens =
        await FirestoreService.getNotifyTokensFromUserList(user);

    // contact list bos
    if (contactTokens == null) return null;

    // contact list bos
    if (contactTokens.isEmpty) return null;

    SharedPreferences pref = await SharedPreferences.getInstance();
    var buffer = new StringBuffer();
    buffer.write(pref.getString("name"));
    buffer.write(" ");
    buffer.write(pref.getString("surname"));
    final name = buffer.toString();
    contactTokens.forEach((_token) async {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Yardıma ihtiyacım var',
              'title': name,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': '$latitude $longitude'
            },
            'to': _token,
          },
        ),
      );
      var data = {'latitude': latitude, 'longitude': longitude};
      await FirestoreService.setNotificationToDb(user.uid, _token, data);
    });

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

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
