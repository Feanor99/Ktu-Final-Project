import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/contacts_list.dart';
import 'package:flutter_app/screens/dm_room.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseAuth auth = FirebaseAuth.instance;
String uid = auth.currentUser.uid.toString();

class UsersList extends StatefulWidget {
  @override
  _UsersList createState() => _UsersList();
}

class _UsersList extends State<UsersList> with SingleTickerProviderStateMixin {
  var userList = [];
  getData() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      var userData = snapshot.data();
      userList = userData['userList'] == null ? [] : userData['userList'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  openMessageRoom(name, receiverPhoneNumber) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DmRoom(
          receiverName: name,
          phoneNumber: receiverPhoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text('Kişilerim'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: (userList == null || userList.length == 0)
                    ? Center(child: Container(child: Text('Kişi listeniz boş')))
                    : ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              title: Text(userList[index]['displayName']),
                              subtitle: Text(userList[index]['phoneNumber']),
                              onTap: () => openMessageRoom(
                                  userList[index]['displayName'],
                                  userList[index]['phoneNumber']),
                              trailing: new Container(
                                  child: new RaisedButton.icon(
                                color: Colors.red,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            userList[index]['displayName']),
                                        content: Text(
                                            userList[index]['phoneNumber']),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("Kişilerimden Sil"),
                                            onPressed: () {
                                              userList.removeWhere((item) =>
                                                  item['phoneNumber'] ==
                                                  userList[index]
                                                      ['phoneNumber']);
                                              DocumentReference user =
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(uid);
                                              user.update({
                                                'userList': userList,
                                              }).then((_) {
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                    msg: "İşlem Başarılı",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.black54,
                                                    timeInSecForIosWeb: 1,
                                                    textColor: Colors.white,
                                                    fontSize: 15.0);
                                                setState(() {});
                                              });
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                label: Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.white),
                                ),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              )),
                              leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: CircleAvatar(
                                      child: Text(
                                          userList[index]['displayName'][0]),
                                      backgroundColor: Colors.transparent)));
                        })),
            Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 60,
                width: 250,
                child: new RaisedButton.icon(
                  color: Colors.blue,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  label: Text(
                    'Yeni Kişi Ekle',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContactList())),
                )),
          ],
        ),
      ),
    );
  }
}
