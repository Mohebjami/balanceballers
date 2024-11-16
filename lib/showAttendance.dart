// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference attendanceRef = FirebaseFirestore.instance.collection('Attendance');

Future<int> getIsPresentLength() async {
  QuerySnapshot querySnapshot = await attendanceRef.get();
  List<DocumentSnapshot> docs = querySnapshot.docs;
  List<DocumentSnapshot> isPresentDocs = docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data != null && data['isPresent'] == true;
  }).toList();

  return isPresentDocs.length;
}
// ignore: must_be_immutable
class AttendanceList extends StatelessWidget {
  late String lsN;

  AttendanceList({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<QuerySnapshot>(
          future: attendanceRef.get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child:  CircularProgressIndicator());
            }
            // Create a map to store the count of names
            Map<String, int> nameCount = {};

            // Iterate over the documents and increment the count for each name
            snapshot.data?.docs.forEach((doc) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
              if (data != null && data.containsKey('Name')) {
                String name = data['Name'];
                lsN = data['Last Name'];
                if (nameCount.containsKey(name)) {
                  nameCount[name] = (nameCount[name] ?? 0) + 1;
                } else {
                  nameCount[name] = 1;
                }
              }
            });

            // Find the names that appear more than once
            List<String> duplicateNames = nameCount.entries
                .where((entry) => entry.value > 1)
                .map((entry) => entry.key)
                .toList();

            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: duplicateNames.length,
                  itemBuilder: (context, index) {
                    String name = duplicateNames[index];
                    return Card(
                      color: const Color.fromRGBO(255, 180, 0, 1.0),
                      child: ListTile(
                        // tileColor: const Color.fromRGBO(255, 180, 0, 1.0),
                        title: Text(name),
                        leading: CircleAvatar(child: Text('${nameCount[name]}')),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


