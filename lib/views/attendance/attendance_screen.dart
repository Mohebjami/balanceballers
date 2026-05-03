import 'package:balanceballers/controllers/attendance_controller.dart';
import 'package:balanceballers/core/utils/search_utils.dart';
import 'package:balanceballers/views/players/player_info_screen.dart';
import 'package:balanceballers/widgets/app_glass_container.dart';
import 'package:balanceballers/widgets/app_mesh_background.dart';
import 'package:balanceballers/widgets/app_search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final AttendanceController _attendanceController = AttendanceController();

  final TextEditingController _searchController = TextEditingController();
  String searchString = '';

  List<Map<String, dynamic>> allData = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // Player Attendance List
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: StreamBuilder<QuerySnapshot>(
              stream: _attendanceController.watchPlayers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                // Filter search
                List<Map<String, dynamic>> filteredData = docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  data['isPresent'] ??= true;
                  return data;
                }).where((data) {
                  return SearchUtils.matchesPlayerName(data, searchString);
                }).toList();

                allData = filteredData;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredData.length,
                  itemBuilder: (_, index) {
                    var data = filteredData[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: AppGlassContainer(
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
                  onPressed: () async {
                    await _attendanceController.saveAttendance(allData);
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
