import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceController {
  AttendanceController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get playersRef => _firestore.collection('players');
  CollectionReference get attendanceRef => _firestore.collection('Attendance');

  Stream<QuerySnapshot> watchPlayers() {
    return playersRef.snapshots();
  }

  Future<void> saveAttendance(List<Map<String, dynamic>> attendance) async {
    for (final data in attendance) {
      await attendanceRef.add({
        'Name': data['Name'],
        'Last Name': data['Last Name'],
        'isPresent': data['isPresent'],
      });
    }
  }
}
