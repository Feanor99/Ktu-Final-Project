import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/notification_location.dart';
import 'package:flutter_app/services/firestore_service.dart';

class NotificationModel {
  String id;
  String senderId;
  String senderName;
  String latitude;
  String longitude;
  Timestamp date;

  NotificationModel(
      {this.id,
      this.senderId,
      this.senderName,
      this.latitude,
      this.longitude,
      this.date});

  goToLocation(BuildContext context) {
    Route route = MaterialPageRoute(
        builder: (context) =>
            NotificationLocation(this.latitude, this.longitude));
    Navigator.push(context, route);
    print("Belirlenen lokasyona git!");
  }

  removeNotification() {
    FirestoreService.removeUserNotifiation(this.id);
  }

  localDate() {
    final datestr =
        DateTime.fromMillisecondsSinceEpoch(this.date.millisecondsSinceEpoch)
            .toLocal()
            .toString();
    final date = datestr.split(' ');
    String _date = date[0];
    dynamic time = date[1];

    time = time.split(':');
    time.removeLast();
    time = time.join(':');

    return _date + ' ' + time;
  }

  render(BuildContext context, dynamic remove) {
    return InkWell(
      onTap: () {
        goToLocation(context);
      },
      child: Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  overflow: TextOverflow.fade,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: this.senderName + ' ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              'Sizden yardım istedi. Hemen tıklayın ve nerede olduğunu öğrenin '),
                      TextSpan(
                        text: '\n' + localDate(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    remove(this.id); // parent function
                  },
                  child: Text("Sil")),
            ],
          ),
        ),
      ),
    );
  }

  static NotificationModel fromJson(Map<String, dynamic> data) {
    final model = NotificationModel(
        id: data['id'],
        senderId: data['senderId'],
        senderName: data['senderName'],
        date: data['date'],
        latitude: data['latitude'],
        longitude: data['longitude']);
    return model;
  }
}
