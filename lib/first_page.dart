import 'package:flutter/material.dart';
import 'package:here_bug/map_widget.dart';
import 'package:here_bug/second_page.dart';

class FirstPage extends StatefulWidget {
  FirstPage({Key key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State {
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
