import 'dart:async';
import 'package:balanceballers/PlayerInfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlayerList extends StatefulWidget {
@override
_PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final CollectionReference playersRef =
  FirebaseFirestore.instance.collection('players');
  final CollectionReference debtorsRef =
  FirebaseFirestore.instance.collection('Debtors');
  String searchString = '';
  Timer? _dailyTimer;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDailyTimer();
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  void _startDailyTimer() {
    _dailyTimer = Timer.periodic(const Duration(days: 1), (timer) async {
      QuerySnapshot snapshot = await playersRef.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime endDate = DateTime.parse(data['End Date']);
        int remainingDays = endDate
            .difference(DateTime.now())
            .inDays;
        if (remainingDays > 0) {
          doc.reference.update(
              {'remainingDays': remainingDays}); // Update 'remainingDays' field
        } else {
          await debtorsRef.add(data);
          await doc.reference.delete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchString = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? playersRef.snapshots()
                  : playersRef.orderBy('Name').startAt([searchString]).endAt(
                  [searchString + '\uf8ff']).snapshots(),
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
                return ListView(
                  children: snapshot.data?.docs.map((
                      DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<
                        String,
                        dynamic>;
                    DateTime endDate = DateTime.parse(data['End Date']);
                    int remainingDays = endDate
                        .difference(DateTime.now())
                        .inDays;

                    return Slidable(
                      closeOnScroll: true,
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.red,
                            icon: Icons.check,
                            label: 'Delete',
                            onPressed: (context) async {
                              await FirebaseFirestore.instance.runTransaction(
                                      (Transaction myTransaction) async {
                                    await myTransaction.delete(
                                        document.reference);
                                  });
                            },
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(data['Name']),
                        leading: CircleAvatar(
                          backgroundColor: remainingDays > 5
                              ? Colors.green
                              : (remainingDays >= 0 ? Colors.yellow : Colors
                              .red), // Change color if remainingDays <= 5
                          child: Text(remainingDays.toString() , style: TextStyle(color: Colors.white)),
                        ),
                        subtitle: Text(data['Last Name']),
                        trailing: Text(data['Debt']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerInfo(data: data),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList() ??
                      [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
