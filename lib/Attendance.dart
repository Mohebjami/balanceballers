import 'dart:async';
import 'package:balanceballers/player_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getwidget/getwidget.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final CollectionReference playersRef =
      FirebaseFirestore.instance.collection('players');

  final TextEditingController _searchController = TextEditingController();
  String searchString = '';

  List<Map<String, dynamic>> allData = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "حاضری",
          style: TextStyle(
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold,
              fontSize: 22),
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

          // Player Attendance List
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: StreamBuilder<QuerySnapshot>(
              stream: playersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                // Filter search
                List<Map<String, dynamic>> filteredData = docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  data['isPresent'] ??= true;
                  return data;
                }).where((data) {
                  if (searchString.trim().isEmpty) return true;
                  String name = data['Name'].toString().toLowerCase();
                  String lastName = data['Last Name'].toString().toLowerCase();
                  return name.contains(searchString) ||
                      lastName.contains(searchString);
                }).toList();

                allData = filteredData;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredData.length,
                  itemBuilder: (_, index) {
                    var data = filteredData[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: _glassContainer(
                        padding: const EdgeInsets.all(8),
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
                          trailing: GFToggle(
                            onChanged: (val) {
                              setState(() {
                                data['isPresent'] = val!;
                              });
                            },
                            value: data['isPresent'],
                            enabledThumbColor: Colors.white,
                            enabledTrackColor: Colors.blueAccent,
                            type: GFToggleType.ios,
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
                    );
                  },
                );
              },
            ),
          ),

          // Save Button at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    for (var data in allData) {
                      FirebaseFirestore.instance
                          .collection('Attendance')
                          .add({
                        'Name': data['Name'],
                        'Last Name': data['Last Name'],
                        'isPresent': data['isPresent'],
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("حاضری ذخیره شد")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "ذخیره",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "TrajanPro",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}