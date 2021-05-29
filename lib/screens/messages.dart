import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    // TODO: implement initState
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
          tempRooms.add({
            'name': recUser['displayName'],
            'phone': recUser['phoneNumber']
          });
        }
      }
    }

    setState(() {
      messageRooms = tempRooms;
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
              itemBuilder: (c, i) {
                return ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DmRoom(
                                receiverName: messageRooms[i]['name'],
                                phoneNumber: messageRooms[i]['phone'],
                              ))),
                  title: Text(messageRooms[i]['name']),
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
