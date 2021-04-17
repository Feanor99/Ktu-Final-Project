import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  goToLocation() {
    print("Belirlenen lokasyona git!");
  }

  removeNotification() {
    FirestoreService.removeUserNotifiation(this.id);
  }

  since() {
    int min = DateTime.now()
        .toUtc()
        .difference(
          this.date.toDate(),
        )
        .inMinutes;

    if (min >= 60) {
      return (min % 60).toString() + 's';
    }

    if (min < 60) {
      return (min).toString() + 'd';
    }
  }

  render(dynamic remove) {
    return InkWell(
      onTap: goToLocation,
      child: Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                        text: since(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    print(this.id);
                    remove(this.id);
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
