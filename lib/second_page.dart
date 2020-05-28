import 'package:flutter/material.dart';
import 'package:here_bug/map_widget.dart';
import 'package:here_sdk/mapview.dart';

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
