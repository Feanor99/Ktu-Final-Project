import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationLocation extends StatefulWidget {
  var latitude;
  var longitude;
  NotificationLocation(this.latitude, this.longitude);
  @override
  State<NotificationLocation> createState() =>
      _NotificationLocation(latitude, longitude);
}

class _NotificationLocation extends State<NotificationLocation> {
  Completer<GoogleMapController> _controller = Completer();
  String latitude;
  String longitude;

  _NotificationLocation(this.latitude, this.longitude);

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId("home"),
          position: LatLng(double.parse(latitude), double.parse(longitude)),
          icon: BitmapDescriptor.defaultMarker),
    ].toSet();
  }

  _cameraPosition() {
    return CameraPosition(
      target: LatLng(double.parse(latitude), double.parse(longitude)),
      zoom: 18,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Yardım istenen konum'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _cameraPosition(),
        markers: _createMarker(),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
