import 'dart:async';
import 'package:balanceballers/player_info.dart';
import 'package:balanceballers/showAttendance.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart' as pdp;

class PlayerList extends StatefulWidget {
  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final CollectionReference playersRef =
      FirebaseFirestore.instance.collection('players');
  final CollectionReference debtorsRef =
      FirebaseFirestore.instance.collection('Debtors');
  final CollectionReference attendanceRef =
      FirebaseFirestore.instance.collection('attendance');

  final TextEditingController _searchController = TextEditingController();
  String searchString = '';
  Timer? _dailyTimer;
  String? _selectedFilterType;

  final List<String> _typeOptions = [
    'صبح',
    'بعد از ظهر',
    'وی ای پی',
    'وی ای پی پیروزی',
    'جوانان',
    'نوجوانان',
    'نونهالان',
  ];

  @override
  void initState() {
    super.initState();
    _startDailyTimer();
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startDailyTimer() {
    _dailyTimer = Timer.periodic(const Duration(days: 1), (timer) async {
      QuerySnapshot snapshot = await playersRef.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime endDate = _convertPersianToDateTime(data['End Date']);
        int remainingDays = endDate.difference(DateTime.now()).inDays;

        if (remainingDays > 0) {
          doc.reference.update({'remainingDays': remainingDays});
        } else {
          await debtorsRef.add(data);
          await doc.reference.delete();
        }
      }
    });
  }

  DateTime _convertPersianToDateTime(Map<String, dynamic> persianDate) {
    try {
      final jalaliDate = pdp.Jalali(
        persianDate['year'],
        persianDate['month'],
        persianDate['day'],
      );
      return jalaliDate.toDateTime();
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDate(Map<String, dynamic>? dateMap) {
    if (dateMap == null) return 'No Date';
    DateTime date = DateTime(dateMap['year'], dateMap['month'], dateMap['day']);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget _glassContainer({required Widget child, EdgeInsets? padding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ?const Color(0xFF0F172A):  Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
           color: isDark ?const Color(0xFF0F172A):  Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark?   Colors.white.withValues(alpha: 0.06) :Colors.black.withValues(alpha: 0.06),
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
          "بازیکنان",
          style: TextStyle(
            fontFamily: "TrajanPro",
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    title: const Text(
                      "فیلتر بر اساس رده سنی",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedFilterType,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "انتخاب رده",
                              ),
                              items: _typeOptions.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDialog(
                                    () => _selectedFilterType = value);
                              },
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilterType = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("حذف فیلتر"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: const Text("اعمال"),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
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
                      style:  TextStyle(color: isDark? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "...جستجو",
                        hintStyle: TextStyle(color: isDark? Colors.white : Colors.black),
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

          if (_selectedFilterType != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Chip(
                  label: Text(
                    "فیلتر فعال: $_selectedFilterType",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.orange.shade600.withValues(alpha: 0.9),
                ),
              ),
            ),

          // Player List
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: StreamBuilder<QuerySnapshot>(
              stream: playersRef.snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
                    .where((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      bool matchesSearch = searchString.trim().isEmpty ||
                          data['Name']
                              .toString()
                              .toLowerCase()
                              .contains(searchString) ||
                          data['Last Name']
                              .toString()
                              .toLowerCase()
                              .contains(searchString);

                      bool matchesType =
                          _selectedFilterType == null ||
                              data['Type'] == _selectedFilterType;

                      return matchesSearch && matchesType;
                    })
                    .toList();

                List<Map<String, dynamic>> playersWithRemainingDays =
                    filteredDocs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  DateTime endDate = _convertPersianToDateTime(data['End Date']);
                  int remainingDays = endDate.difference(DateTime.now()).inDays;

                  return {
                    'doc': doc,
                    'data': data,
                    'remainingDays': remainingDays,
                  };
                }).toList();

                playersWithRemainingDays.sort((a, b) {
                  DateTime dateA = _convertPersianToDateTime(a['data']['Date']);
                  DateTime dateB = _convertPersianToDateTime(b['data']['Date']);
                  return dateA.compareTo(dateB);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: playersWithRemainingDays.length,
                  itemBuilder: (_, index) {
                    var player = playersWithRemainingDays[index];
                    Map<String, dynamic> data = player['data'];
                    int remainingDays = player['remainingDays'];

                    Color remainingColor = remainingDays > 5
                        ? Colors.green.shade500
                        : remainingDays >= 0
                            ? Colors.amber.shade600
                            : Colors.red.shade600;

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
                                  await FirebaseFirestore.instance
                                      .runTransaction(
                                          (Transaction myTransaction) async {
                                    String name = data['Name'];
                                    String lastName = data['Last Name'];

                                    QuerySnapshot attendanceSnapshot =
                                        await attendanceRef
                                            .where('Name', isEqualTo: name)
                                            .where('Last Name',
                                                isEqualTo: lastName)
                                            .get();

                                    for (var doc
                                        in attendanceSnapshot.docs) {
                                      await doc.reference.delete();
                                    }

                                    myTransaction
                                        .delete(player['doc'].reference);
                                  });
                                },
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerInfo(data: data),
                                ),
                              );
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              trailing: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                                  ),
                                  CircleAvatar(
                                    radius: 21,
                                    backgroundColor: remainingColor,
                                    child: Text(
                                      remainingDays.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                "${data['Name']} ${data['Last Name']}",
                                textAlign: TextAlign.right,
                                style:  TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                _formatDate(data['Date']),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 13.5,
                                ),
                              ),
                              leading: Chip(
                                backgroundColor: Colors.red.shade400,
                                label: Text(
                                  data['Debt'].toString(),
                                  style:  TextStyle(
                                      color: isDark ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
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