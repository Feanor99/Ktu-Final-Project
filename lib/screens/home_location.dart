import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_app/services/get_location.dart';
import 'package:flutter_app/widgets/why_need_location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeLocation extends StatefulWidget {
  @override
  _HomeLocation createState() => _HomeLocation();
}

class _HomeLocation extends State<HomeLocation> {
  updateLocation() async {
    var location = await GetLocation.checkPermissionThenGetLocation();
    bool granted = false;

    if (location == null) {
      await LocationHelper.locationNeededFor(context);
      location = await GetLocation.checkPermissionThenGetLocation();
      if (location == null) {
        await LocationHelper.locationNeededFor(context, showSettingBut: true);
      } else
        granted = true;
    } else
      granted = true;

    if (granted) {
      var latitude = location.latitude.toString();
      var longitude = location.longitude.toString();
      String userLocation = latitude + ", " + longitude;
      await FirestoreService.updateHomeLocation(userLocation);
      Fluttertoast.showToast(
          msg: "Ev konumunuz kaydedildi",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 15.0);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool("homeLocationStatus", true);
      Navigator.pop(context);
    }
  }

  isHomeLocationSaved() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool check = pref.getBool("homeLocationStatus") ?? false;
    return check;
  }

  String butonText = "Kaydet";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool result = await isHomeLocationSaved();
      if (this.mounted && result) {
        setState(() {
          butonText = "Güncelle";
        });
      }
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ev konumu'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 30),
            child: Text(
              "Merhaba, Eğer evinizde iseniz aşağıdaki butona basarak konumunuzu işaretleyebilirsiniz. Bu bilgi ile ev konumunuza yakın olası bir deprem meydana gelmesi durumunda, bildirim yoluyla size ulaşmaya çalışacağız. (Daha sonra bu ayarı güncelleyebilirsiniz)",
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextButton.icon(
              onPressed: () => updateLocation(),
              icon: Icon(
                Icons.home,
                color: Colors.white,
                size: 40,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              label: Text(
                butonText,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ))
        ],
      ),
    );
  }
}
