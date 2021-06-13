import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ToplanmaAlanlari extends StatefulWidget {
  @override
  _ToplanmaAlanlari createState() => _ToplanmaAlanlari();
}

class _ToplanmaAlanlari extends State<ToplanmaAlanlari>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  String title, url;
  bool isLoading = true;
  final _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Toplanma Alanları'),
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            key: _key,
            initialUrl:
                "https://www.turkiye.gov.tr/afet-ve-acil-durum-yonetimi-acil-toplanma-alani-sorgulama",
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(),
        ],
      ),
    );
  }
}
