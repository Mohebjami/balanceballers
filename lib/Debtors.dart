import 'dart:async';
import 'package:balanceballers/player_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Debtors extends StatefulWidget {
  @override
  _DebtorsState createState() => _DebtorsState();
}

class _DebtorsState extends State<Debtors> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Debtors');

  final TextEditingController _searchController = TextEditingController();
  String searchString = '';

  // Dropdown & Add Debt
  Map<String, String?>? selectedPlayer;
  List<Map<String, String?>> playerDropDown = [];
  final TextEditingController debtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    debtController.dispose();
    super.dispose();
  }

  Future<void> fetchPlayers() async {
    final snapshots =
        await FirebaseFirestore.instance.collection('players').get();
    playerDropDown = snapshots.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'Name': data['Name'] as String?,
        'Last Name': data['Last Name'] as String?,
      };
    }).toList();
    setState(() {});
  }

  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildMeshBackground(bool isDark) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF020617)]
                : [Colors.white, Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double fullScreenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "قرض دار ها",
          style: TextStyle(
            fontFamily: "TrajanPro",
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Stack(
        children: [
          _buildMeshBackground(isDark),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _glassContainer(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchString = value.toLowerCase();
                        });
                      },
                      style:
                          TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "...جستجو",
                        hintStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Debtors List
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchString.trim() == '')
                  ? collectionRef.snapshots()
                  : collectionRef
                      .where('Name', isGreaterThanOrEqualTo: searchString)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    var doc = docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: _glassContainer(
                        padding: const EdgeInsets.all(8),
                        child: Slidable(
                          closeOnScroll: true,
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_forever_rounded,
                                label: 'حذف',
                                borderRadius: BorderRadius.circular(16),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                onPressed: (context) async {
                                  await doc.reference.delete();
                                },
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            title: Text(
                              "${data['Name']} ${data['Last Name']}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "قرض: ${data['Debt']}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 14),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade400,
                              child: Text(
                                data['Debt'].toString(),
                                style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerInfo(data: data),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Add debt dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor:
                    isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: debtController,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "قرض",
                          hintStyle: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: DropdownButton<Map<String, String?>>(
                          value: selectedPlayer,
                          hint: const Center(
                            child: Text(
                              "انتخاب بازیکن",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.orange.shade600,
                          underline: Container(color: Colors.transparent),
                          icon: const Icon(Icons.arrow_downward,
                              color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              selectedPlayer = value;
                            });
                          },
                          items: playerDropDown
                              .map((player) => DropdownMenuItem(
                                    alignment: Alignment.centerRight,
                                    value: player,
                                    child: Text(
                                        "${player['Name']} ${player['Last Name']}"),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: fullScreenWidth,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedPlayer != null &&
                                debtController.text.isNotEmpty) {
                              int dbt = int.parse(debtController.text);

                              // Update or add debtor
                              final collRef =
                                  FirebaseFirestore.instance.collection('Debtors');
                              Query query = collRef
                                  .where('Name',
                                      isEqualTo: selectedPlayer?['Name'])
                                  .where('Last Name',
                                      isEqualTo: selectedPlayer?['Last Name']);

                              final querySnapshot = await query.get();
                              if (querySnapshot.docs.isNotEmpty) {
                                for (var doc in querySnapshot.docs) {
                                  await doc.reference.update({'Debt': dbt});
                                }
                              } else {
                                await collRef.add({
                                  'Name': selectedPlayer?['Name'],
                                  'Last Name': selectedPlayer?['Last Name'],
                                  'Debt': dbt,
                                });
                              }
                              debtController.clear();
                              selectedPlayer = null;
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          child: const Text(
                            "ذخیره",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}