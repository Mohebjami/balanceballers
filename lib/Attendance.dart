import 'package:balanceballers/player_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final CollectionReference playersRef =
  FirebaseFirestore.instance.collection('players');
  late List<Map<String, dynamic>> allData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "حاضری",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: playersRef.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                allData = snapshot.data?.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  data['isPresent'] = true; // default value
                  return data;
                }).toList() ??
                    [];
                return ListView(
                  children: allData.map((data) {
                    return ListTile(
                      title: Text(data['Name']),
                      subtitle: Text(data['Last Name']),
                      trailing: SizedBox(
                          child: GFToggle(
                            onChanged: (val) {
                              data['isPresent'] = val!;
                            },
                            value: data['isPresent'],
                            enabledThumbColor: Colors.white,
                            enabledTrackColor:
                            const Color.fromRGBO(255, 180, 0, 1.0),
                            type: GFToggleType.ios,
                          )),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerInfo(data: data),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () {
                    for (var data in allData) {
                      FirebaseFirestore.instance.collection('Attendance').add({
                        'Name': data['Name'],
                        'Last Name': data['Last Name'],
                        'isPresent': data['isPresent'],
                      });
                    }
                  },
                  color: const Color.fromRGBO(255, 180, 0, 1.0),
                  child: const Text(
                    "ذخیره",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "TrajanPro",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
