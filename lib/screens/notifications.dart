import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/notification_modal.dart';
import 'package:flutter_app/services/firestore_service.dart';

class Notifications extends StatefulWidget {
  Notifications({Key key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<NotificationModel> mNotifications = [];
  User user = FirebaseAuth.instance.currentUser;

  getNotify() async {
    final notifies = await FirestoreService.getUserNotifications();

    setState(() {
      mNotifications = notifies;
    });
  }

  removeNotification(String id) {
    List<NotificationModel> newNotifies = [];
    this.mNotifications.forEach((element) {
      if (element.id != id) {
        newNotifies.add(element);
      }
    });

    setState(() {
      mNotifications = newNotifies;
    });
    print(id);
    FirestoreService.removeUserNotifiation(id);
  }

  @override
  void initState() {
    super.initState();
    getNotify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bildirimler"),
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (ctx, index) => Divider(
            color: Colors.grey,
          ),
          itemCount: mNotifications.length,
          itemBuilder: (BuildContext ctx, int index) {
            return mNotifications[index].render(removeNotification);
          },
        ),
      ),
    );
  }
}
