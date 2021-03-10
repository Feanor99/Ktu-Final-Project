import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationLocation extends StatefulWidget {
  static var latitude;
  static var longitude;

  @override
  State<NotificationLocation> createState() => _NotificationLocation();
}

class _NotificationLocation extends State<NotificationLocation> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId("home"),
          position: LatLng(double.parse(NotificationLocation.latitude),
              double.parse(NotificationLocation.longitude)),
          icon: BitmapDescriptor.defaultMarker),
    ].toSet();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(double.parse(NotificationLocation.latitude),
        double.parse(NotificationLocation.longitude)),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        markers: _createMarker(),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
