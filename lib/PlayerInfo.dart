import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class PlayerInfo extends StatelessWidget {
  final Map data;

  PlayerInfo({Key? key, required this.data}) : super(key: key);

  Future<int> getAttendanceCount(String userId, bool isPresent) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .where('userId', isEqualTo: userId)
        .where('isPresent', isEqualTo: isPresent)
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Player Info',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
                  radius: 120,
                  child: Text(
                    data['Name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "TrajanPro",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 100, // Adjust this value as needed
              child: Row(
                children: [
                  Expanded(
                    flex: 1, // Adjust this value as needed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Last Name',style: TextStyle(fontSize: 30),),
                        const SizedBox(
                          height: 10,
                        ),
                        Text('${data['Last Name']}',style: const TextStyle(fontSize: 30),),
                      ],
                    ),
                  ),
                  const VerticalDivider(color: Color.fromRGBO(255, 180, 0, 1.0), thickness: 2,),
                  Expanded(
                    flex: 1, // Adjust this value as needed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Debt',style: TextStyle(fontSize: 30),),
                        Text('${data['Debt']}',style: const TextStyle(fontSize: 30),),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: Divider(
                color: Color.fromRGBO(255, 180, 0, 1.0),
                thickness: 2,
              ),
            ),
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('End Date',style: const TextStyle(fontSize: 25),),
                        Text('${data['End Date']}',style: const TextStyle(fontSize: 25),)
                      ],
                    ),
                  ),
                  const VerticalDivider(color: Color.fromRGBO(255, 180, 0, 1.0), thickness: 2,),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Register Date',style: const TextStyle(fontSize: 25),),
                        Text('${data['Date'][0]}/${data['Date'][1]}/${data['Date'][2]}', style: const TextStyle(fontSize: 25),),
                      ],
                    ),
                  )
                ],
              ),
            ),



            if (data.containsKey('userId') && data['userId'] != null)
              FutureBuilder<int>(
                future: getAttendanceCount(data['userId'], true),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                    return Text('Present Count: ${snapshot.data}');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            if (data.containsKey('userId') && data['userId'] != null)
              FutureBuilder<int>(
                future: getAttendanceCount(data['userId'], false),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                    return Text('Absent Count: ${snapshot.data}');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
          ],
        ),
      ),
    );
  }
}
