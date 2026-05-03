import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference attendanceRef =
    FirebaseFirestore.instance.collection('Attendance');

Future<int> getIsPresentLength() async {
  QuerySnapshot querySnapshot = await attendanceRef.get();
  List<DocumentSnapshot> docs = querySnapshot.docs;
  List<DocumentSnapshot> isPresentDocs = docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data != null && data['isPresent'] == true;
  }).toList();

  return isPresentDocs.length;
}

class AttendanceList extends StatelessWidget {
  const AttendanceList({super.key});

  Widget _glassContainer(
      {required Widget child, EdgeInsets? padding, bool isDark = false}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(1),
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
              fontSize: 22,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Stack(
        children: [
          _buildMeshBackground(isDark),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<QuerySnapshot>(
              future: attendanceRef.get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Count names
                Map<String, int> nameCount = {};
                Map<String, String> lastNameMap = {};

                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic>? data =
                      doc.data() as Map<String, dynamic>?;
                  if (data != null && data.containsKey('Name')) {
                    String name = data['Name'];
                    String lastName = data['Last Name'] ?? '';
                    lastNameMap[name] = lastName;
                    nameCount[name] = (nameCount[name] ?? 0) + 1;
                  }
                }

                List<String> names = nameCount.keys.toList();

                return ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    String name = names[index];
                    int count = nameCount[name]!;
                    String lastName = lastNameMap[name]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: _glassContainer(
                        isDark: isDark,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade600,
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            name,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            lastName,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
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
    );
  }
}
