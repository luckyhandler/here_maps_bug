import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

class MapWidget extends StatefulWidget {
  MapWidget({this.scheme = MapScheme.greyDay});

  final MapScheme scheme;

  @override
  State<MapWidget> createState() {
    return MapState();
  }
}

class MapState extends State<MapWidget> {
  final Geolocator _locationProvider = Geolocator();

  Position _position;
  MapPolygon _mapPolygon;
  HereMapController _mapController;
  double _distanceInMetersFromPosition = 2500;

  StreamSubscription<Position> _subscription;

  @override
  void initState() {
    super.initState();
    showInitialPosition();
    _subscription =
        _locationProvider.getPositionStream().listen((Position position) {
      if (position != null) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HereMap(
      key: widget.key,
      onMapCreated: (mapController) => _onMapCreated(context, mapController),
    );
  }

  Future<void> _onMapCreated(
      BuildContext context, HereMapController mapController) async {
    mapController.gestures;
    _mapController = mapController;
    mapController.mapScene.loadSceneForMapScheme(widget.scheme,
        (MapError error) {
      if (error != null) {
        debugPrint(error.toString());
        return;
      }

      final GeoCoordinates coordinates =
          GeoCoordinates(_position.latitude, _position.longitude);

      _showPosition(coordinates, _position.accuracy);
    });
  }

  void _showPosition(
      final GeoCoordinates coordinates, final double accuracy) async {
    if (coordinates == null || accuracy == null) {
      return;
    }

    if (_mapPolygon != null) {
      _mapController.mapScene.removeMapPolygon(_mapPolygon);
    }
    _mapPolygon = MapPolygon(
        GeoPolygon.withGeoCircle(GeoCircle(coordinates, accuracy)),
        Color(Colors.blue.red, Colors.blue.green, Colors.blue.blue));
    _mapController.mapScene.addMapPolygon(_mapPolygon);

    _mapController.camera
        .lookAtPointWithDistance(coordinates, _distanceInMetersFromPosition);
  }

  void showInitialPosition() async {
    Position position = await _locationProvider.getLastKnownPosition();
    if (position != null) {
      setState(() {
        _position = position;
      });
    }
  }
}
