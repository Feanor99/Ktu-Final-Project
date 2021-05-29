import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DmRoom extends StatefulWidget {
  final String receiverName;
  final String phoneNumber;
  DmRoom({Key key, this.receiverName, this.phoneNumber}) : super(key: key);

  @override
  _DmRoomState createState() => _DmRoomState();
}

class _DmRoomState extends State<DmRoom> {
  CollectionReference roomRef;
  Map<String, dynamic> room;
  String currentMessage;
  var _controller = TextEditingController();
  var listController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  String userName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        userName = value.getString('name');
      });
    });
    FirestoreService.GetDmRoom(widget.phoneNumber).then((_room) {
      if (_room != null) {
        roomRef = FirebaseFirestore.instance
            .collection('dmRooms')
            .doc(_room['uid'])
            .collection('messages');
      }
      setState(() {
        room = _room;
      });
    });
  }

  Future sendMessage(String msg) async {
    if (room == null) {
      roomRef = await FirestoreService.CreateDmRoom(widget.phoneNumber);

      final _room = {
        'uid': roomRef.parent.id,
        'receiverPhoneNumber': widget.phoneNumber
      };

      setState(() {
        room = _room;
      });
    }

    var message = {
      'content': msg,
      'createdAt': Timestamp.now(),
      'senderId': user.uid
    };

    await roomRef.add(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white60,
              child: room != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: roomRef
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Bir seyler yanlis gitti');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Mesajlar yukleniyor.");
                        }
                        return new ListView(
                          controller: listController,
                          shrinkWrap: true,
                          reverse: true,
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) {
                            var data = document.data();
                            return new ListTile(
                              title: new Text(
                                data['senderId'] == user.uid
                                    ? userName
                                    : widget.receiverName,
                                textAlign: data['senderId'] == user.uid
                                    ? TextAlign.left
                                    : TextAlign.right,
                              ),
                              subtitle: new Text(
                                data['content'],
                                textAlign: data['senderId'] == user.uid
                                    ? TextAlign.left
                                    : TextAlign.right,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  : Text("Mesaj yok"),
            ),
          ),
          Container(
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      onChanged: (m) => currentMessage = m,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(0),
                        hintText: 'Bir mesaj girin',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      sendMessage(currentMessage);
                      _controller.clear();
                      currentMessage = "";
                    },
                    child: Text("Send"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
