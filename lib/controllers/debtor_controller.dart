import 'package:cloud_firestore/cloud_firestore.dart';

class DebtorController {
  DebtorController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get debtorsRef => _firestore.collection('Debtors');
  CollectionReference get playersRef => _firestore.collection('players');

  Stream<QuerySnapshot> watchDebtors() {
    return debtorsRef.snapshots();
  }

  Future<List<Map<String, String?>>> fetchPlayerDropdown() async {
    final snapshots = await playersRef.get();

    return snapshots.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'Name': data['Name'] as String?,
        'Last Name': data['Last Name'] as String?,
      };
    }).toList();
  }

  Future<void> upsertDebt({
    required Map<String, String?> player,
    required int debt,
  }) async {
    final querySnapshot = await debtorsRef
        .where('Name', isEqualTo: player['Name'])
        .where('Last Name', isEqualTo: player['Last Name'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'Debt': debt});
      }
      return;
    }

    await debtorsRef.add({
      'Name': player['Name'],
      'Last Name': player['Last Name'],
      'Debt': debt,
    });
  }
}
