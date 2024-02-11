import 'package:balanceballers/Debtors.dart';
import 'package:balanceballers/Players.dart';
import 'package:balanceballers/Register.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
    @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Balance Ballers"),
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
