import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/help_me.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/screens/deprem_hazirlik.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoYouSafe extends StatefulWidget {
  @override
  _DoYouSafe createState() => _DoYouSafe();
}

class _DoYouSafe extends State<DoYouSafe> {
  final String serverToken =
      'AAAAXTCsRjI:APA91bEVJujo9YTgZgB1KwgJJBYjLavDx857efILIh7mkJCw_XZeMu1Qu-gF5tCSwtoshyZTJoo913uQjHcz7DnIovDytqTFPHm7pgmuuveTG_Yye_ngxVMWQ2eW3f8d1UQnLBZXBOCU';

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String msg) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final contactTokens =
        await FirestoreService.getNotifyTokensFromUserList(user);
    if (contactTokens.length <= 0 || contactTokens == null)
      return null; // TOKEN YOK

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
              'body': '$msg',
              'title': name,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'notification_id': '3',
            },
            'to': _token,
          },
        ),
      );
    });

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }

  doYouSafeDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: Text('Durumunuz'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Ev Konumunuza Yakın >5.5 büyüklüğünde deprem oldu.',
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Center(child: Text('Güvendeyim')),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.green; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      sendAndRetrieveMessage(
                          "Deprem hissettim ve Güvendeyim lütfen hatları meşgul etme");
                      Navigator.pop(context);
                      Route route = MaterialPageRoute(
                          builder: (context) => DepremHazirlik());
                      Navigator.pushReplacement(context, route);
                      Fluttertoast.showToast(
                          msg: "Güvende olduğunuz bildirildi.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black54,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          fontSize: 15.0);
                    }),
                ElevatedButton(
                    child: Center(child: Text('Yardım')),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.red; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Route route =
                          MaterialPageRoute(builder: (context) => HelpMe());
                      Navigator.pushReplacement(context, route);
                    }),
              ],
            ));
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (this.mounted) doYouSafeDialog();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Yönlendiriliyor...',
            style: TextStyle(fontSize: 20.0),
          )
        ],
      ),
    ));
  }
}
