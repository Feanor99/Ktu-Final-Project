import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> addContact(String phoneNumber, String displayName) {
  CollectionReference usersList =
      FirebaseFirestore.instance.collection('usersList');
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser.uid.toString();
  usersList.add(
      {'displayName': displayName, 'phoneNumber': phoneNumber, 'uid': uid});
}

class ContactList extends StatefulWidget {
  ContactList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ContactList createState() => _ContactList();
}

class _ContactList extends State<ContactList> {
  bool _isLoading = true;
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    setState(() {
      contacts = _contacts;
    });
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kişilerim'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10, bottom: 25),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    labelText: 'Ara',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(
                            color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor)),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: isSearching == true
                          ? contactsFiltered.length
                          : contacts.length,
                      itemBuilder: (context, index) {
                        Contact contact = isSearching == true
                            ? contactsFiltered[index]
                            : contacts[index];

                        var baseColor =
                            contactsColorMap[contact.displayName] as dynamic;

                        Color color1 = baseColor[800];
                        Color color2 = baseColor[400];
                        return ListTile(
                            title: Text(contact.displayName),
                            subtitle: Text(contact.phones.length > 0
                                ? contact.phones.elementAt(0).value
                                : ''),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(contact.displayName),
                                    content: Text(contact.phones.length > 0
                                        ? contact.phones.elementAt(0).value
                                        : ''),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Kişilerime Kaydet"),
                                        onPressed: () {
                                          addContact(
                                              contact.phones.length > 0
                                                  ? contact.phones
                                                      .elementAt(0)
                                                      .value
                                                  : '',
                                              contact.displayName);
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg: "Başarıyla Eklendi",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.black54,
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
                            trailing: new Container(
                                child: new RaisedButton.icon(
                              color: Colors.blue,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(contact.displayName),
                                      content: Text(contact.phones.length > 0
                                          ? contact.phones.elementAt(0).value
                                          : ''),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Kişilerime Kaydet"),
                                          onPressed: () {
                                            addContact(
                                                contact.phones.length > 0
                                                    ? contact.phones
                                                        .elementAt(0)
                                                        .value
                                                    : '',
                                                contact.displayName);
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                                msg: "Başarıyla Eklendi",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.black54,
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
                                'Ekle',
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            )),
                            leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                        colors: [
                                          color1,
                                          color2,
                                        ],
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight)),
                                child: CircleAvatar(
                                    child: Text(contact.initials(),
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.transparent)));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
