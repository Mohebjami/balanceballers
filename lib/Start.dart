import 'package:balanceballers/Debtors.dart';
import 'package:balanceballers/Players.dart';
import 'package:balanceballers/Register.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  final Function toggleTheme;

  const Start({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool _isLightTheme = false; // Declare _isLightTheme

  bool get isLightTheme => _isLightTheme; // Getter for _isLightTheme

  set isLightTheme(bool value) { // Setter for _isLightTheme
    setState(() {
      _isLightTheme = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _isLightTheme ? const Color.fromRGBO(10, 23, 42,1) : const Color.fromRGBO(255, 255, 240, 1),
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
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: Padding(
          padding: const EdgeInsets.only(left: 13.0, top: 0,right: 13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               const Text(
                "Mottahid futsal academy",
                style: TextStyle(fontSize: 40, fontFamily: "ProtestGuerrilla"),
              ),
              const SizedBox(
                height: 60,
              ),
               Center(
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/pic/logo.png"),fit: BoxFit.contain)
                  ),
                 
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Center(
                child: SizedBox(
                  width: fullScreenWidth-120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(255, 180, 0, 1))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Register()),
                              );
                            },
                            child: const Text("Register" , style: TextStyle(fontSize: 20,fontFamily: "TrajanPro", fontWeight: FontWeight.bold),)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(255, 180, 0, 1))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PlayerList()),
                              );
                            },
                            child: const Text("Players", style: TextStyle(fontSize: 20,fontFamily: "TrajanPro", fontWeight: FontWeight.bold),)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(255, 180, 0, 1))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Debtors()),
                              );
                            },
                            child: const Text("Debtors", style: TextStyle(fontSize: 20,fontFamily: "TrajanPro", fontWeight: FontWeight.bold),)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(255, 180, 0, 1))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Debtors()),
                              );
                            },
                            child: const Text("Free Player", style: TextStyle(fontSize: 20,fontFamily: "TrajanPro", fontWeight: FontWeight.bold),)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
