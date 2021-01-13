import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/contacts_list.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseAuth auth = FirebaseAuth.instance;
String uid = auth.currentUser.uid.toString();

class UsersList extends StatefulWidget {
  @override
  _UsersList createState() => _UsersList();
}

class _UsersList extends State<UsersList> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primarySwatch: Colors.blue, // page deafult font type
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Kişilerim'),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('usersList')
                        .where('uid', isEqualTo: uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                        return Center(
                            child: Container(
                          child: Text('Kişi listeniz boş'),
                        ));
                      }
                      return ListView(
                        children: snapshot.data.docs.map((document) {
                          return ListTile(
                              title: Text(document['displayName']),
                              subtitle: Text(document['phoneNumber']),
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
                                        title: Text(document['displayName']),
                                        content: Text(document['phoneNumber']),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("Kişilerimden Sil"),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('usersList')
                                                  .doc(document.id)
                                                  .delete();
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                  msg: "İşlem Başarılı",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.black54,
                                                  timeInSecForIosWeb: 1,
                                                  textColor: Colors.white,
                                                  fontSize: 15.0);
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
                                      child: Text(document['displayName'][0]),
                                      backgroundColor: Colors.transparent)));
                        }).toList(),
                      );
                    }),
              ),
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
      ),
    );
  }
}
