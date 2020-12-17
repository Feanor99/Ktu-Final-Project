import 'package:flutter/material.dart';
import 'package:flutter_app/left_menu.dart';
import 'package:flutter_app/deprem_hazirlik.dart';
import 'package:flutter_app/toplanma_alanlari.dart';
import 'screens/deprem_liste.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: "Deprem Acil Yardım",
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ))
          ],
        ),
      ),
    );
  }
}
