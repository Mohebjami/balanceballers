import 'dart:async';
import 'package:balanceballers/controllers/player_controller.dart';
import 'package:balanceballers/core/utils/search_utils.dart';
import 'package:balanceballers/views/players/player_info_screen.dart';
import 'package:balanceballers/widgets/app_glass_container.dart';
import 'package:balanceballers/widgets/app_mesh_background.dart';
import 'package:balanceballers/widgets/app_search_field.dart';
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
  final PlayerController _playerController = PlayerController();

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
      QuerySnapshot snapshot = await _playerController.getPlayers();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime? endDate = _convertPersianToDateTime(data['End Date']);
        if (endDate == null) continue;

        int remainingDays = endDate.difference(DateTime.now()).inDays;

        if (remainingDays > 0) {
          _playerController.updateRemainingDays(doc.reference, remainingDays);
        } else {
          await _playerController.moveToDebtorsAndDelete(doc.reference, data);
        }
      }
    });
  }

  DateTime? _convertPersianToDateTime(dynamic persianDate) {
    if (persianDate is! Map) return null;

    try {
      final jalaliDate = pdp.Jalali(
        _readDatePart(persianDate['year']),
        _readDatePart(persianDate['month']),
        _readDatePart(persianDate['day']),
      );
      return jalaliDate.toDateTime();
    } catch (e) {
      return null;
    }
  }

  int _readDatePart(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }

  String _formatDate(dynamic dateMap) {
    DateTime? date = _convertPersianToDateTime(dateMap);
    if (date == null) return 'No Date';

    return DateFormat('yyyy-MM-dd').format(date);
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
                              initialValue: _selectedFilterType,
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
                  backgroundColor:
                      Colors.orange.shade600.withValues(alpha: 0.9),
                ),
              ),
            ),

          // Player List
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: StreamBuilder<QuerySnapshot>(
              stream: _playerController.watchPlayers(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> filteredDocs =
                    snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  bool matchesSearch =
                      SearchUtils.matchesPlayerName(data, searchString);

                  bool matchesType = _selectedFilterType == null ||
                      data['Type'] == _selectedFilterType;

                  return matchesSearch && matchesType;
                }).toList();

                List<Map<String, dynamic>> playersWithRemainingDays =
                    filteredDocs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  DateTime? endDate = _convertPersianToDateTime(
                    data['End Date'],
                  );
                  int? remainingDays =
                      endDate?.difference(DateTime.now()).inDays;

                  return {
                    'doc': doc,
                    'data': data,
                    'remainingDays': remainingDays,
                    'registeredAt': _convertPersianToDateTime(data['Date']),
                  };
                }).toList();

                playersWithRemainingDays.sort((a, b) {
                  DateTime dateA =
                      a['registeredAt'] as DateTime? ?? DateTime(9999);
                  DateTime dateB =
                      b['registeredAt'] as DateTime? ?? DateTime(9999);
                  return dateA.compareTo(dateB);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: playersWithRemainingDays.length,
                  itemBuilder: (_, index) {
                    var player = playersWithRemainingDays[index];
                    Map<String, dynamic> data = player['data'];
                    int? remainingDays = player['remainingDays'];

                    Color remainingColor = remainingDays == null
                        ? Colors.grey.shade500
                        : remainingDays > 5
                            ? Colors.green.shade500
                            : remainingDays >= 0
                                ? Colors.amber.shade600
                                : Colors.red.shade600;

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
                                  await _playerController
                                      .deletePlayerAndAttendance(
                                    playerReference: player['doc'].reference,
                                    name: data['Name'].toString(),
                                    lastName: data['Last Name'].toString(),
                                  );
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
                                    backgroundColor:
                                        Colors.grey.withValues(alpha: 0.15),
                                  ),
                                  CircleAvatar(
                                    radius: 21,
                                    backgroundColor: remainingColor,
                                    child: Text(
                                      remainingDays?.toString() ?? '-',
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
                                style: TextStyle(
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
                                  style: TextStyle(
                                      color:
                                          isDark ? Colors.black : Colors.white,
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
