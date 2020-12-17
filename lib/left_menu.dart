import 'package:flutter/material.dart';
import 'package:flutter_app/deprem_hazirlik.dart';
import 'package:flutter_app/toplanma_alanlari.dart';
import 'screens/deprem_liste.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.red,
          padding: const EdgeInsets.all(20),
          child: Center(
              child: Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/deprem.png'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.circle,
                ),
              )
            ],
          )),
        ),
        Card(
            child: ListTile(
          leading: Icon(Icons.info_sharp),
          title: Text('Acil Durum Rehberi',
              style: TextStyle(
                fontSize: 16,
              )),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => DepremHazirlik())),
        )),
        Card(
            child: ListTile(
          leading: Icon(Icons.dashboard),
          title: Text('Son Depremler',
              style: TextStyle(
                fontSize: 16,
              )),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ShakeListScreen())),
        )),
        Card(
            child: ListTile(
          leading: Icon(Icons.directions_run),
          title: Text('Toplanma Alanları',
              style: TextStyle(
                fontSize: 16,
              )),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ToplanmaAlanlari())),
        )),
      ],
    ));
  }
}
