import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerController {
  PlayerController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get playersRef => _firestore.collection('players');
  CollectionReference get debtorsRef => _firestore.collection('Debtors');
  CollectionReference get attendanceRef => _firestore.collection('attendance');

  Stream<QuerySnapshot> watchPlayers() {
    return playersRef.snapshots();
  }

  Future<QuerySnapshot> getPlayers() {
    return playersRef.get();
  }

  Future<void> updateRemainingDays(
    DocumentReference reference,
    int remainingDays,
  ) {
    return reference.update({'remainingDays': remainingDays});
  }

  Future<void> moveToDebtorsAndDelete(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) async {
    await debtorsRef.add(data);
    await reference.delete();
  }

  Future<void> deletePlayerAndAttendance({
    required DocumentReference playerReference,
    required String name,
    required String lastName,
  }) async {
    final attendanceSnapshot = await attendanceRef
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName)
        .get();

    for (final doc in attendanceSnapshot.docs) {
      await doc.reference.delete();
    }

    await playerReference.delete();
  }
}
