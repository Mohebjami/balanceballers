import 'package:balanceballers/Debtors.dart';
import 'package:balanceballers/Players.dart';
import 'package:balanceballers/Register.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  final Function toggleTheme;

  const Start({Key? key,  required this.toggleTheme}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  get _isLightTheme => true;

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) => GestureDetector(
            child: const CircleAvatar(
              backgroundImage: AssetImage("assets/football.png"),
              radius: 20.0,
            ),
            onTap: () {},
          ),
        ),
        actions: <Widget>[
          SizedBox(
            width: 70,
            height: 40,
            child: FittedBox(
              child: Switch(
                value: _isLightTheme,
                onChanged: (value) {
                  widget.toggleTheme();
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.blueGrey,
                inactiveTrackColor: Colors.grey,
                activeTrackColor: Colors.orange,
                activeThumbImage: const AssetImage('assets/sun.png'),
                inactiveThumbImage: const AssetImage('assets/moon.png'),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              }, child: const Text("Register")),
              ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  PlayerList()),
                );
              }, child: const Text("Players")),
              ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Debtors()),
                );
              }, child: const Text("Debtors")),
            ],
          ),
        ),
      ),
    );
  }
}
