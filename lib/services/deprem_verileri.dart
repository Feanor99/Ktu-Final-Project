import 'dart:convert';

import 'package:flutter_app/models/shake.dart';
import 'package:http/http.dart' as http;

class ShakeDatas {
  static Future<List<Shake>> getShakeData() async {
    var response = await http.get("https://turkiyedepremapi.herokuapp.com/api");
    //If the http request is successful the statusCode will be 200
    if (response.statusCode == 200) {
      String htmlToParse = response.body;

      dynamic data = json.decode(htmlToParse);
      List<Shake> temp = [];
      data.forEach((value) {
        temp.add(Shake.fromJson(value));
      });
      return temp;
    }
    return null;
  }
}
