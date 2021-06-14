import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/users_list.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactList extends StatefulWidget {
  ContactList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ContactList createState() => _ContactList();
}

class _ContactList extends State<ContactList> {
  bool _isLoading = true;
  bool _isNULL = false;
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();

  Future addContact(String phoneNumber, String displayName) async {
    final isExist = await doesPhoneAlreadyExist(phoneNumber);
    if (isExist) {
      Fluttertoast.showToast(
          msg: "Bu kişiyi zaten eklediniz.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 15.0);
      return;
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    var user = [
      {
        'displayName': displayName,
        'phoneNumber': convertToValidNumber(phoneNumber)
      }
    ];

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'userList': FieldValue.arrayUnion(user)}).then((_) {
      Fluttertoast.showToast(
          msg: "Başarıyla Eklendi",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 15.0);
    });
  }

  String convertToValidNumber(str) {
    if (str == "") return null;

    str = str.replaceAll(new RegExp(r"\D"), "");

    str = str[0] == '+' ? str.substring(1) : str;
    str = str[0] == '9' ? str.substring(1) : str;
    str = str[0] == '0' ? str.substring(1) : str;
    str = '+90' + str;
    return str;
  }

  Future getUserData(user_id) async {
    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user_id).get();
    return snapshot.data();
  }

  Future<bool> doesPhoneAlreadyExist(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();
    var userData = await getUserData(uid);
    var userList = userData['userList'] == null ? [] : userData['userList'];
    var phones = [];
    for (var i = 0; i < userList.length; i++) {
      phones.add(userList[i]['phoneNumber']);
    }
    return phones.contains(convertToValidNumber(phoneNumber));
  }

  Future<bool> doesUserExist(String phoneNumber) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: convertToValidNumber(phoneNumber))
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }

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
    List<String> contactListString = [];
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

    for (var i in _contacts) {
      if (i.phones.isNotEmpty) {
        contactListString.add(i.phones.elementAt(0).value);
      } else {
        contactListString.add('');
      }
    }

    Map<int, String> phoneList = {};

    for (int i = 0; i < contactListString.length; i++) {
      final str =
          convertToValidNumber(flattenPhoneNumber(contactListString[i]));
      if (str != null) {
        phoneList[i] = str;
      }
    }

    List<dynamic> registeredPhoneNos = await FirestoreService.getAllUserPhone();

    registeredPhoneNos.map((val) => val.toString()).toList();

    List<Contact> tempContancts = [];

    for (var entr in phoneList.entries) {
      if (registeredPhoneNos.contains(entr.value)) {
        tempContancts.add(_contacts[entr.key]);
      }
    }

    // for (int i = 0; i < _contacts.length; i++) {
    //   var contact = _contacts[i];
    //   if (phoneList.containsKey(i)) {
    //     if (registeredPhoneNos.contains(phoneList[i])) {
    //       tempContancts.add(contact);
    //     }
    //   }
    // }

    setState(() {
      contacts = tempContancts;
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (contacts.length == 0) _isNULL = true;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsersList()),
          ).then((value) => setState(() {})),
        ),
        title: Text('Yeni Kişi Ekle'),
        backgroundColor: Colors.blue,
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
                        borderSide: new BorderSide(color: Colors.blue)),
                    prefixIcon: Icon(Icons.search, color: Colors.blue)),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _isNULL
                      ? Center(child: Text("Kayıtlı Kullanıcı Bulunamadı."))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: isSearching == true
                              ? contactsFiltered.length
                              : contacts.length,
                          itemBuilder: (context, index) {
                            Contact contact = isSearching == true
                                ? contactsFiltered[index]
                                : contacts[index];
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
                                            onPressed: () async {
                                              if (contact.phones.length > 0) {
                                                await addContact(
                                                    contact.phones
                                                        .elementAt(0)
                                                        .value,
                                                    contact.displayName);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Telefon Numarası Gereklidir",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.black54,
                                                    timeInSecForIosWeb: 1,
                                                    textColor: Colors.white,
                                                    fontSize: 15.0);
                                              }
                                              Navigator.pop(context);
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
                                          content: Text(
                                              contact.phones.length > 0
                                                  ? contact.phones
                                                      .elementAt(0)
                                                      .value
                                                  : ''),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Kişilerime Kaydet"),
                                              onPressed: () async {
                                                if (contact.phones.length > 0) {
                                                  await addContact(
                                                      contact.phones
                                                          .elementAt(0)
                                                          .value,
                                                      contact.displayName);
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Telefon Numarası Gereklidir",
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                          Colors.black54,
                                                      timeInSecForIosWeb: 1,
                                                      textColor: Colors.white,
                                                      fontSize: 15.0);
                                                }
                                                Navigator.pop(context);
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
                                        color: Colors.blue),
                                    child: CircleAvatar(
                                        child: Text(contact.initials(),
                                            style:
                                                TextStyle(color: Colors.white)),
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
