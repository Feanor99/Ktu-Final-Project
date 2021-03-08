import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/message.dart';
import 'package:flutter_app/screens/help_me.dart';
import 'package:flutter_app/screens/notification_location.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_app/services/get_location.dart';
import 'package:flutter_app/widgets/left_menu.dart';
import 'package:flutter_app/screens/users_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/deprem_liste.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'package:flutter_app/main.dart': (BuildContext context) => MyHomePage(),
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthService().handleAuth(),
      //home: NotificationLocation(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic data;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //check if phone already has an account
  Future<dynamic> firestoreUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var location = await GetLocation.checkPermissionThenGetLocation();

    String userLocation =
        location.latitude.toString() + ", " + location.longitude.toString();

    String phone = pref.getString("phone") ?? "";
    if (phone == "") return;

    final user = FirebaseAuth.instance.currentUser;
    final id = user.uid;

    FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: id)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Fluttertoast.showToast(
            msg: "Telefonunuz kayıtlı, tekrar hoşgeldiniz.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 15.0);
        FirestoreService.updateUserNotifyIdAndLocation(userLocation);
      } else {
        String name = pref.getString("name") ?? "";
        String surname = pref.getString("surname") ?? "";

        FirestoreService.addUser(name, surname, phone, userLocation);

        Fluttertoast.showToast(
            msg: "Kaydınız tamamlandı. Hoşgeldiniz.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 15.0);
      }
    }).catchError((e) => print("error fetching data: $e"));
  }

  checkUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool check = pref.getBool("first") ?? false;
    if (!check) {
      pref.setBool("first", true);
      firestoreUserData();
    }
  }

  checkNotificationData() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        Fluttertoast.showToast(
            msg: message.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 15.0);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    checkNotificationData();

    /* firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage : $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch : $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message");
      },
    );
    if (Platform.isIOS) {
      firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );
    }*/ //DEPRECATED

    checkUser();
    /*  WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.popUntil(
          context,
          ModalRoute.withName('/'),
        ));*/ //this code might be useless but dont delete
    Message message = new Message(
        "merhaba nasılsınız acaba aaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccc");
    message.encryptAndSendMessage();
    print("---------");
    message.decryptRecivedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MainDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 210,
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/deprem3.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                  ],
                )),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: FlatButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShakeListScreen())),
                    color: Colors.blue,
                    minWidth: 230,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Column(
                      // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.dashboard, color: Colors.white),
                        Text(
                          "Son Depremler",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )
                      ],
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: FlatButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UsersList())),
                  color: Colors.green,
                  minWidth: 230,
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.contacts, color: Colors.white),
                      Text(
                        "Kişilerim",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: FlatButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HelpMe())),
                  color: Colors.orange,
                  minWidth: 230,
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.warning, color: Colors.white),
                      Text(
                        "Yardım İste",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
