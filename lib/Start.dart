// ignore: file_names
import 'package:balanceballers/Attendance.dart';
import 'package:balanceballers/Debtors.dart';
import 'package:balanceballers/Free_Player.dart';
import 'package:balanceballers/Players.dart';
import 'package:balanceballers/Register.dart';
import 'package:balanceballers/ShowFreePalyer.dart';
import 'package:balanceballers/showAttendance.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  final Function toggleTheme;

  const Start({super.key, required this.toggleTheme});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool _isLightTheme = false;

  bool get isLightTheme => _isLightTheme;

  set isLightTheme(bool value) {
    setState(() {
      _isLightTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _isLightTheme
          ? const Color.fromRGBO(10, 23, 42, 1)
          : const Color.fromRGBO(255, 255, 240, 1),
      appBar: AppBar(
        title: Builder(
          builder: (context) => GestureDetector(
            child: const CircleAvatar(
              backgroundImage: AssetImage("assets/pic/football.png"),
              backgroundColor: Colors.transparent,
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
                  setState(() {
                    _isLightTheme = value;
                    widget.toggleTheme();
                  });
                },
                activeColor: Colors.blueGrey,
                inactiveThumbColor: Colors.yellow,
                inactiveTrackColor: Colors.orange,
                activeTrackColor: Colors.grey,
                inactiveThumbImage: const AssetImage('assets/pic/sun.png'),
                activeThumbImage: const AssetImage('assets/pic/moon.png'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
        children: [
          const Text(
            "Mottahed futsal academy",
            style: TextStyle(fontSize: 40, fontFamily: "ProtestGuerrilla"),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              height: 270,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/pic/logo.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._buildNavigationButtons(fullScreenWidth, context),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationButtons(
      double fullScreenWidth, BuildContext context) {
    final buttonData = [
      {"text": "ثبت نام", "destination": const Register()},
      {"text": "بازیکنان", "destination": PlayerList()},
      {"text": "قرض دارها", "destination": Debtors()},
      {"text": "ثبت نام رایگان", "destination": const Free_Player()},
      {"text": "دیدن بازیکنان رایگان", "destination": ShowFreePlayer()},
      {"text": "حاضری", "destination": const Attendance()},
      {"text": "دیدن حاضری", "destination": AttendanceList()},
    ];

    return buttonData
        .map(
          (data) => Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: SizedBox(
              height: 50,
              width: fullScreenWidth - 120,
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromRGBO(255, 180, 0, 1.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => data['destination'] as Widget),
                  );
                },
                child: Text(
                  data['text'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: "TrajanPro",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
