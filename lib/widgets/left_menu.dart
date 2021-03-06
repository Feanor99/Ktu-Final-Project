import 'package:flutter/material.dart';
import 'package:flutter_app/screens/deprem_hazirlik.dart';
import 'package:flutter_app/screens/home_location.dart';
import 'package:flutter_app/screens/messages.dart';
import 'package:flutter_app/screens/toplanma_alanlari.dart';
import 'package:flutter_app/screens/toplanma_alanlari_izmir.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          height: 165.0,
          color: Colors.red,
          padding: const EdgeInsets.all(20),
          child: Center(
              child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 25), child:
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
              )],
          ),),
        ),
        Card(
            child: ListTile(
                leading: Icon(Icons.info_sharp),
                title: Text('Acil Durum Rehberi',
                    style: TextStyle(
                      fontSize: 16,
                    )),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DepremHazirlik()));
                })),
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
        Card(
          child: ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Toplanma Alanları (İzmir)',
                style: TextStyle(
                  fontSize: 16,
                )),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ToplanmaAlanlariIzmir())),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.message),
            title: Text('Mesajlarım',
                style: TextStyle(
                  fontSize: 16,
                )),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Messages())),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text('Ev Konumum',
                style: TextStyle(
                  fontSize: 16,
                )),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomeLocation())),
          ),
        ),
      ],
    ));
  }
}
