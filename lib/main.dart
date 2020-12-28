import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:flutter_app/users/list_users.dart';
import 'package:flutter_app/users/sign_up.dart';
import 'package:flutter_app/widgets/left_menu.dart';
import 'package:flutter_app/screens/deprem_hazirlik.dart';
import 'package:flutter_app/screens/toplanma_alanlari.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/deprem_liste.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthService().handleAuth(),
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
  checkUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool check = pref.getBool("first") ?? false;
    if (!check) {
      String name = pref.getString("name") ?? "";
      String surname = pref.getString("surname") ?? "";
      String phone = pref.getString("phone") ?? "";
      SignUp().addUser(name, surname, phone);
      pref.setBool("first", true);
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
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
                          builder: (context) => DepremHazirlik())),
                  color: Colors.blue,
                  minWidth: 230,
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.info_sharp, color: Colors.white),
                      Text(
                        "Acil Durum Rehberi",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                )),
            Container(
                margin: EdgeInsets.only(bottom: 15),
                child: FlatButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShakeListScreen())),
                  color: Colors.green,
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
                margin: EdgeInsets.only(bottom: 40),
                child: FlatButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ToplanmaAlanlari())),
                  color: Colors.orange,
                  minWidth: 230,
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.directions_run, color: Colors.white),
                      Text(
                        "Toplanma Alanları",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                )),
            Container(
                child: FlatButton(
              onPressed: () => ListUsers().printThemAll(),
              color: Colors.orange,
              minWidth: 230,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Text(
                    "Print users to console",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
