import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static locationNeededFor(BuildContext context,
      {bool showSettingBut = false}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konum İzni'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                showSettingBut
                    ? Text(
                        'Uygulama ayarlarından konum izni vermenizi rica ediyoruz.',
                        style: TextStyle(fontSize: 18.0),
                      )
                    : Text(
                        'Konumunuzu kişilerinize eklediğiniz kişilerden başka kimse görememektedir, Uygulamaya tam fonksiyonel kullanabilmek için konum izni vermenizi rica ediyoruz',
                        style: TextStyle(fontSize: 18.0),
                      )
              ],
            ),
          ),
          actions: <Widget>[
            showSettingBut
                ? ElevatedButton(
                    child: Center(child: Text('Ayarlar')),
                    onPressed: () async {
                      Navigator.pop(context);
                      await openAppSettings();
                    })
                : ElevatedButton(
                    child: Center(child: Text('Tamam')),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
          ],
        );
      },
    );
  }
}
