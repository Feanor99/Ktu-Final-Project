import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/dm_room.dart';
import 'package:flutter_app/screens/users_list.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Messages extends StatefulWidget {
  Messages({Key key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  var messageRooms = [];
  String myName;
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();

    getAllMessageRooms();
  }

  Future getAllMessageRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = await FirestoreService.getUserDataWithPhoneNumber(
        prefs.getString('phone'));

    if (!userData.containsKey('dmRooms')) return;
    if (!userData.containsKey('userList')) return;
    var tempRooms = [];
    for (var el in userData['dmRooms'].values) {
      for (var recUser in userData['userList']) {
        if (recUser['phoneNumber'] == el['receiverPhoneNumber']) {
          QuerySnapshot qs = await FirebaseFirestore.instance
              .collection('dmRooms')
              .doc(el['uid'])
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

          var msgData = qs.docs[0].data();
          msgData['createdAt'] = msgData['createdAt']
              .toDate()
              .toLocal()
              .toString()
              .split(':')
              .getRange(0, 2)
              .join(':');

          tempRooms.add({
            'name': recUser['displayName'],
            'phone': recUser['phoneNumber'],
            'uid': el['uid'],
            'lastMessage': msgData
          });
        }
      }
    }

    setState(() {
      messageRooms = tempRooms;
      myName = prefs.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mesajlarım"),
      ),
      body: messageRooms.length > 0
          ? ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.black,
              ),
              itemCount: messageRooms.length,
              padding: EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (c, i) {
                return ListTile(
                  trailing: Text(messageRooms[i]['lastMessage']['createdAt']),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DmRoom(
                                receiverName: messageRooms[i]['name'],
                                phoneNumber: messageRooms[i]['phone'],
                              ))),
                  title: Text(messageRooms[i]['name']),
                  subtitle: Text(
                    (messageRooms[i]['lastMessage']['senderId'] == user.uid
                            ? myName
                            : messageRooms[i]['name']) +
                        ": " +
                        messageRooms[i]['lastMessage']['content'],
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Text(messageRooms[i]['name'][0]),
                  ),
                );
              },
            )
          : Text("Henuz hic mesajin yok"),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_comment_outlined),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => UsersList())),
      ),
    );
  }
}
