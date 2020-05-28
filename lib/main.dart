import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HERE Maps Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(16.0),
        child: FloatingActionButton(
          child: Icon(Icons.navigate_next),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SecondPage(),
            ),
          ),
        ),
      ),
    );
  }
}

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
        Color(Colors.green.red, Colors.green.green, Colors.green.blue));
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

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<int> list = List<int>.generate(10, (i) => i + 1);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
                expandedHeight: 250.0,
                floating: true,
                pinned: true,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Second Screen'),
                  background: MapWidget(scheme: MapScheme.greyNight),
                )),
          ];
        },
        body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            int item = list[index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: Icon(Icons.map),
                title: Text('item $item'),
                subtitle: Text('$item from ${list.length} items'),
              ),
            );
          },
        ),
      ),
    );
  }
}
