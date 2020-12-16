import 'dart:convert';

Shake getShakeFromJson(String str) => Shake.fromJson(json.decode(str));

class Shake {
  Shake(
      {this.date,
      this.time,
      this.latitude,
      this.longitude,
      this.depht,
      this.size,
      this.location,
      this.city});

  String date;
  String time;
  String latitude;
  String longitude;
  String depht;
  String size;
  String location;
  String city;

  factory Shake.fromJson(Map<String, dynamic> json) => Shake(
        date: json['tarih'],
        time: json['saat'],
        latitude: json['enlem'],
        longitude: json['boylam'],
        depht: json['derinlik'],
        size: json['buyukluk'],
        location: json['yer'],
        city: json['sehir'],
      );
}
