import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/shake.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ShakeListScreen extends StatefulWidget {
  @override
  _ShakeListScreenState createState() => _ShakeListScreenState();
}

class _ShakeListScreenState extends State<ShakeListScreen> {
  List<Shake> shakeList = [];
  bool _isLoading = true;

  final List<String> months = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Ekim",
    "Kasım",
    "Aralık"
  ];

  getShakeDatas() async {
    var response = await http.get("https://turkiyedepremapi.herokuapp.com/api");
    //If the http request is successful the statusCode will be 200
    if (response.statusCode == 200) {
      String htmlToParse = response.body;

      dynamic data = json.decode(htmlToParse);
      List<Shake> temp = [];
      data.forEach((value) {
        temp.add(Shake.fromJson(value));
      });

      if (temp == null) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Lütfen internet bağlantınızı kontrol edip tekrar deneyiniz.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      shakeList =
          temp.where((element) => double.parse(element.size) > 3.0).toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getShakeDatas();
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Son Depremler"),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              strokeWidth: 10,
            ))
          : Container(
              margin: EdgeInsets.only(top: 5),
              child: ListView.builder(
                  itemCount: shakeList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        height: 90,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      months[int.parse(shakeList[index]
                                              .date
                                              .split('.')[1]) -
                                          1],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      shakeList[index].date.split('.')[2],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      shakeList[index].date.split('.')[0],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 5,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shakeList[index].location,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(shakeList[index].city),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(color: Colors.grey))),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      shakeList[index].size,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red),
                                    ),
                                    Text(
                                      shakeList[index].time.substring(0, 5),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ));
                  }),
            ),
    );
  }
}
