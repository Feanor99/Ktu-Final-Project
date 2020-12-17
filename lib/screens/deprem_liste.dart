import 'package:flutter/material.dart';
import 'package:flutter_app/models/shake.dart';
import 'package:flutter_app/services/deprem_verileri.dart';

class ShakeListScreen extends StatefulWidget {
  @override
  _ShakeListScreenState createState() => _ShakeListScreenState();
}

class _ShakeListScreenState extends State<ShakeListScreen> {
  List<Shake> shakeList = [];

  getShakeDatas() async {
    final temp = await ShakeDatas.getShakeData();

    setState(() {
      shakeList = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    getShakeDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Son Depremler"),
        backgroundColor: Colors.green,
      ),
      body: shakeList == null
          ? Text("Once verileri cek ")
          : ListView.builder(
              itemCount: shakeList.length,
              itemExtent: 90,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Yer : ${shakeList[index].location}"),
                        Text("Tarih : ${shakeList[index].date}"),
                        Text("Saat : ${shakeList[index].time}"),
                        Text("Buyukluk : ${shakeList[index].size}"),
                      ],
                    ));
              }),
    );
  }
}
