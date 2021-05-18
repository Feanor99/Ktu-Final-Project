import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

FirebaseAuth auth = FirebaseAuth.instance;
String uid = auth.currentUser.uid.toString();

class ToplanmaAlanlariIzmir extends StatefulWidget {
  @override
  _ToplanmaAlanlariIzmir createState() => _ToplanmaAlanlariIzmir();
}

class _ToplanmaAlanlariIzmir extends State<ToplanmaAlanlariIzmir>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    readJson();
  }

  bool _isLoading = true;
  List _items = [];
  List _newList = [];
  List _newList2 = [];
  List _lastItems = [];
  List _lastItems2 = [];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/izmir.json');
    final data = await json.decode(response);
    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    var userData = snapshot.data();
    var homeLocation =
        userData["homeLocation"] == '' ? '0, 0' : userData["homeLocation"];
    var result1 = homeLocation.split(', ');
    var homeLat = result1[0];
    var homeLon = result1[1];

    var lastLocation =
        userData["lastLocation"] == '' ? '0, 0' : userData["lastLocation"];
    var result2 = lastLocation.split(', ');
    var lastLat = result2[0];
    var lastLon = result2[1];

    setState(() {
      _items = data["items"];
      for (var i = 0; i < _items.length; i++) {
        var lt2 = _items[i]["enlem"];
        var ln2 = _items[i]["boylam"];
        var distance1 = calcCrow(homeLat, homeLon, lt2, ln2);
        var distance2 = calcCrow(lastLat, lastLon, lt2, ln2);
        _newList.add({"index": i, "distance": distance1});
        _newList2.add({"index": i, "distance": distance2});
      }
      _newList.sort((a, b) => a['distance'].compareTo(b['distance']));
      _newList2.sort((a, b) => a['distance'].compareTo(b['distance']));
      for (var i = 0; i < 4; i++) {
        _lastItems.add(_items[_newList[i]['index']]);
        _lastItems2.add(_items[_newList2[i]['index']]);
      }
      _isLoading = false;
    });
  }

  static Future<void> openMap(String latitude, String longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  double calcCrow(String lt1, String ln1, String lt2, String ln2) {
    var R = 6371;
    double lat1 = double.parse(lt1);
    double lat2 = double.parse(lt2);
    double lon1 = double.parse(ln1);
    double lon2 = double.parse(ln2);
    var dLat = toRad(lat2 - lat1);
    var dLon = toRad(lon2 - lon1);
    lat1 = toRad(lat1);
    lat2 = toRad(lat2);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }

  double toRad(value) {
    var pi = 3.1415926535897932;
    return (value * pi) / 180;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('En Yakın Toplanma Alanları'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: "Evinize Göre",
              ),
              Tab(
                text: "Son Konumunuza Göre",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _lastItems.length > 0
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: _lastItems.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        margin: EdgeInsets.all(10),
                                        child: ListTile(
                                          leading: Text(_lastItems[index]
                                                  ["ilce"]
                                              .toString()),
                                          title: Text(_lastItems[index]
                                                  ["mahalle"]
                                              .toString()),
                                          subtitle: Text(_lastItems[index]
                                                  ["adres"]
                                              .toString()),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              GestureDetector(
                                                  child: Icon(
                                                    Icons.location_pin,
                                                    color: Colors.red,
                                                  ),
                                                  onTap: () => openMap(
                                                      _lastItems[index]["enlem"]
                                                          .toString(),
                                                      _lastItems[index]
                                                              ["boylam"]
                                                          .toString())),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(child: Text("Veri alınamadı."))
                        ],
                      ),
                    ),
            ),
            Center(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _lastItems2.length > 0
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: _lastItems2.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        margin: EdgeInsets.all(10),
                                        child: ListTile(
                                          leading: Text(_lastItems2[index]
                                                  ["ilce"]
                                              .toString()),
                                          title: Text(_lastItems2[index]
                                                  ["mahalle"]
                                              .toString()),
                                          subtitle: Text(_lastItems2[index]
                                                  ["adres"]
                                              .toString()),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              GestureDetector(
                                                  child: Icon(
                                                    Icons.location_pin,
                                                    color: Colors.red,
                                                  ),
                                                  onTap: () => openMap(
                                                      _lastItems2[index]
                                                              ["enlem"]
                                                          .toString(),
                                                      _lastItems2[index]
                                                              ["boylam"]
                                                          .toString())),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(child: Text("Veri alınamadı."))
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
