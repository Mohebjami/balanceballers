import 'package:flutter/material.dart';

class PlayerInfo extends StatelessWidget {
  final Map data;

  PlayerInfo({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${data['Name']}'),
            Text('Last Name: ${data['Last Name']}'),
            Text('Debt: ${data['Debt']}'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
