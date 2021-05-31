import 'dart:convert';

Earthquake getEarthquakeFromJson(String str) =>
    Earthquake.fromJson(json.decode(str));

class Earthquake {
  Earthquake(
      {this.date,
      this.time,
      this.latitude,
      this.longitude,
      this.depht,
      this.size,
      this.location,
      this.city,
      this.distict});

  String date;
  String time;
  String latitude;
  String longitude;
  String depht;
  String size;
  String location;
  String city;
  String distict;

  factory Earthquake.fromJson(Map<String, dynamic> json) => Earthquake(
      date: json['tarih'],
      time: json['saat'],
      latitude: json['enlem'],
      longitude: json['boylam'],
      depht: json['derinlik'],
      size: json['buyukluk'],
      location: json['yer'],
      city: json['sehir'],
      distict: json['ilce']);
}
