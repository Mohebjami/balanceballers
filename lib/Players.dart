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
  final TextEditingController _searchController = TextEditingController();
  String searchString = '';
  Timer? _dailyTimer;
  String? _selectedFilterType;
  final List<String> _typeOptions = [
    'صبح',
    'بعد از ظهر',
    'وی ای پی',
    'جوانان',
    'نوجوانان',
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
    _dailyTimer = Timer.periodic(
      const Duration(days: 1), (timer) async {
      QuerySnapshot snapshot = await playersRef.get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime endDate = _convertPersianToDateTime(data['End Date']);
        int remainingDays = endDate.difference(DateTime.now()).inDays;
        if (remainingDays > 0) {
          doc.reference.update(
              {'remainingDays': remainingDays});
        } else {
          await debtorsRef.add(data);
          await doc.reference.delete();
        }
      }
    }
    );
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
      print('Error converting Persian date: $e');
      return DateTime.now();
    }
  }

  String _formatDate(Map<String, dynamic>? dateMap) {
    if (dateMap == null) return 'No Date';
    DateTime date = DateTime(
      dateMap['year'],
      dateMap['month'],
      dateMap['day'],
    );
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "بازیکنان",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStateDialog) {
                      return AlertDialog(
                        title: const Text("فیلتر بر اساس رده سنی"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromRGBO(255, 180, 0, 1.0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedFilterType,
                                hint: const Text('انتخاب رده سنی'),
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                underline: Container(),
                                onChanged: (String? newValue) {
                                  setStateDialog(() {
                                    _selectedFilterType = newValue;
                                  });
                                },
                                items: _typeOptions
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  child: const Text('حذف فیلتر'),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilterType = null;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('اعمال فیلتر'),
                                  onPressed: () {
                                    setState(() {
                                      // _selectedFilterType is already updated
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
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
                labelText: "جستجو",
                hintText: "جستجو",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          if (_selectedFilterType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'فیلتر: $_selectedFilterType',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFilterType = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchString.trim() == '' && _selectedFilterType == null)
                  ? playersRef.snapshots()
                  : playersRef.snapshots(),
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

                // Filter and process the data
                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  
                  // Apply search filter
                  bool matchesSearch = searchString.trim() == '' ||
                      data['Name'].toString().toLowerCase().contains(searchString) ||
                      data['Last Name'].toString().toLowerCase().contains(searchString);
                  
                  // Apply type filter if selected
                  bool matchesType = _selectedFilterType == null ||
                      data['Type'] == _selectedFilterType;
                  
                  return matchesSearch && matchesType;
                }).toList();

                // Store the player documents in a list and calculate remainingDays
                List<Map<String, dynamic>> playersWithRemainingDays =
                    filteredDocs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  DateTime endDate =
                      _convertPersianToDateTime(data['End Date']);
                  int remainingDays = endDate.difference(DateTime.now()).inDays;
                  return {
                    'doc': doc,
                    'data': data,
                    'remainingDays': remainingDays,
                  };
                }).toList();

                // Sort the list by registration date (earliest registered players first)
                playersWithRemainingDays.sort((a, b) {
                  DateTime dateA = _convertPersianToDateTime(a['data']['Date']);
                  DateTime dateB = _convertPersianToDateTime(b['data']['Date']);
                  return dateA.compareTo(dateB);
                });

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: playersWithRemainingDays.length,
                    itemBuilder: (context, index) {
                      var player = playersWithRemainingDays[index];
                      DocumentSnapshot document = player['doc'];
                      Map<String, dynamic> data = player['data'];
                      int remainingDays = player['remainingDays'];

                      return Card(
                        color: const Color.fromRGBO(255, 180, 0, 1.0),
                        child: Column(
                          children: [
                            Slidable(
                              closeOnScroll: true,
                              startActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete_forever,
                                    label: 'حذف',
                                    onPressed: (context) async {
                                      await FirebaseFirestore.instance
                                          .runTransaction(
                                        (Transaction myTransaction) async {
                                          String name = data['Name'];
                                          String lastName = data['Last Name'];
                                          QuerySnapshot attendanceSnapshot =
                                              await attendanceRef
                                                  .where('Name',
                                                      isEqualTo: name)
                                                  .where('Last Name',
                                                      isEqualTo: lastName)
                                                  .get();
                                          for (var doc
                                              in attendanceSnapshot.docs) {
                                            await doc.reference.delete();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Deleted'),
                                              ),
                                            );
                                          }
                                          myTransaction
                                              .delete(document.reference);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                    "${data['Name'].toString()} ${data['Last Name']}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                leading: CircleAvatar(
                                  backgroundColor: remainingDays > 5
                                      ? Colors.green
                                      : (remainingDays >= 0
                                          ? Colors.yellow
                                          : Colors.red),
                                  child: Text(remainingDays.toString(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                subtitle: Text(_formatDate(data['Date']),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                trailing: Text(data['Debt'].toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlayerInfo(data: data),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}