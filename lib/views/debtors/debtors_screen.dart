import 'dart:async';
import 'package:balanceballers/controllers/debtor_controller.dart';
import 'package:balanceballers/core/utils/search_utils.dart';
import 'package:balanceballers/views/players/player_info_screen.dart';
import 'package:balanceballers/widgets/app_glass_container.dart';
import 'package:balanceballers/widgets/app_mesh_background.dart';
import 'package:balanceballers/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Debtors extends StatefulWidget {
  @override
  _DebtorsState createState() => _DebtorsState();
}

class _DebtorsState extends State<Debtors> {
  final DebtorController _debtorController = DebtorController();

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
    playerDropDown = await _debtorController.fetchPlayerDropdown();
    setState(() {});
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
          AppMeshBackground(isDark: isDark),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppSearchField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchString = value;
                });
              },
            ),
          ),

          // Debtors List
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: StreamBuilder<QuerySnapshot>(
              stream: _debtorController.watchDebtors(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return SearchUtils.matchesPlayerName(data, searchString);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    var doc = docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: AppGlassContainer(
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

                              await _debtorController.upsertDebt(
                                player: selectedPlayer!,
                                debt: dbt,
                              );
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
