import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_app/services/authservice.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final formKey2 = new GlobalKey<FormState>();

  String phoneNo, verificationId, smsCode, name, surname;

  bool codeSent = false, loading = false;

  showAuthDialog() {
    //context null geliyor bazen
    if (context == null) return;
    AwesomeDialog(
      context: context,
      dismissOnBackKeyPress: false,
      title: 'KAYIT OL',
      animType: AnimType.SCALE,
      dismissOnTouchOutside: false,
      dialogType: DialogType.INFO,
      body: Center(
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Text('Kayıt Olun',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0))),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Lütfen İsminizi Giriniz.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Adınız', counter: Offstage()),
                      maxLength: 25,
                      onChanged: (val) {
                        setState(() {
                          this.name = val;
                        });
                      },
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Lütfen Soyadınızı Giriniz.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: 'Soyadınız', counter: Offstage()),
                      maxLength: 25,
                      onChanged: (val) {
                        setState(() {
                          this.surname = val;
                        });
                      },
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return '5551234567 şeklinde giriniz';
                        }
                        return null;
                      },
                      maxLength: 10,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'Telefon No 5551234567',
                          counter: Offstage()),

                      onChanged: (val) {
                        setState(() {
                          this.phoneNo = '+90' + val;
                        });
                      },
                    )),
                if (!loading)
                  Padding(
                      padding: EdgeInsets.only(left: 25.0, right: 25.0),
                      child: ElevatedButton(
                          child: Center(
                              child:
                                  codeSent ? Text('Doğrula') : Text('Gönder')),
                          onPressed: () async {
                            if (!codeSent) {
                              if (formKey.currentState.validate()) {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.setString("name", name);
                                pref.setString("surname", surname);
                                pref.setString("phone", phoneNo);
                                verifyPhone(phoneNo);
                                Navigator.pop(context);
                                showSmsDialog();
                              }
                            }
                          })),
                if (loading) CircularProgressIndicator()
              ],
            )),
      ),
      desc: 'This is also Ignored',
    )..show();
  }

  showSmsDialog() {
    AwesomeDialog(
      context: context,
      title: 'Sms',
      dismissOnBackKeyPress: false,
      animType: AnimType.SCALE,
      dismissOnTouchOutside: false,
      dialogType: DialogType.INFO,
      body: Center(
        child: Form(
            key: formKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (value) {
                        if (value.length != 6) {
                          return '6 haneli kodu giriniz';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: 'Sms kodu'),
                      onChanged: (val) {
                        setState(() {
                          this.smsCode = val;
                        });
                      },
                    )),
                if (!loading)
                  Padding(
                      padding: EdgeInsets.only(left: 25.0, right: 25.0),
                      child: ElevatedButton(
                          child: Center(child: Text('Doğrula')),
                          onPressed: () async {
                            if (formKey2.currentState.validate()) {
                              AuthService().signInWithOTP(
                                  smsCode,
                                  verificationId,
                                  context,
                                  name,
                                  surname,
                                  phoneNo);
                            }
                          })),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: ElevatedButton(
                        child: Center(child: Text('Geri')),
                        onPressed: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                          this.codeSent = false;
                          showAuthDialog();
                        })),
              ],
            )),
      ),
      desc: 'This is also Ignored',
    )..show();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => showAuthDialog());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Yönlendiriliyor...',
            style: TextStyle(fontSize: 20.0),
          )
        ],
      ),
    ));
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
      Navigator.pop(context);
    };

    final PhoneVerificationFailed verificationfailed = (var authException) {
      print('${authException.message}');
      Fluttertoast.showToast(
          msg: "İşlem tamamlanırken sorun oluştu.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          backgroundColor: Colors.black54,
          fontSize: 15.0);
      Navigator.pop(context);
      showAuthDialog();
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      Fluttertoast.showToast(
          msg: "Kodun süresi doldu",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 15.0);
      setState(() {
        this.codeSent = false;
      });
      Navigator.pop(context);
      showAuthDialog();
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
