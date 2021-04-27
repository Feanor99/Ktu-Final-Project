import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/help_me.dart';

import 'package:flutter_app/screens/deprem_hazirlik.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DidYouFeel extends StatefulWidget {
  final id;
  DidYouFeel(this.id);
  @override
  _DidYouFeel createState() => _DidYouFeel(id);
}

class _DidYouFeel extends State<DidYouFeel> {
  final id;
  _DidYouFeel(this.id);
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
                      'Ev Konumunuza Yakın deprem oldu. Hissettiniz mi?',
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Center(child: Text('Hissettim')),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.green; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () async {
                      await FirestoreService.feltThisEarthQuake(id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          msg: "Geri Bildiriminiz Alındı",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black54,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          fontSize: 15.0);
                    }),
                ElevatedButton(
                    child: Center(child: Text('Hayır')),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.green; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          msg: "Geri Bildiriminiz Alındı",
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
