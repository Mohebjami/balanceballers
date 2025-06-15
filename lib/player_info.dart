// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class PlayerInfo extends StatefulWidget {
  final Map data;
  const PlayerInfo({super.key, required this.data});

  @override
  State<PlayerInfo> createState() => _PlayerInfoState();
}

class _PlayerInfoState extends State<PlayerInfo> {
  Future<int> getAttendanceCount(String userId, bool isPresent) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .where('userId', isEqualTo: userId)
        .where('isPresent', isEqualTo: isPresent)
        .get();
    return querySnapshot.docs.length;
  }

  final List<String> _typeOptions = [
    'صبح',
    'بعد از ظهر',
    'وی ای پی',
    'وی ای پی پیروزی',
    'جوانان',
    'نوجوانان',
    'نونهالان',
  ];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // Initialize with current value
    _selectedType = widget.data['Type'];
  }

  TextEditingController nameController = TextEditingController();

  TextEditingController lastController = TextEditingController();

  TextEditingController feeController = TextEditingController();

  TextEditingController periodController = TextEditingController();

  TextEditingController debtorController = TextEditingController();

  String dropdownValue = 'Week';

  Jalali? _selectedDate;

  final bool _isLightTheme = false;
// Theme state
  String? _selectedPeriod = 'Week';
// Default period
  Future<void> _selectDate(BuildContext context) async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedDate ?? Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1450),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
// Show period selection dialog
      _showPeriodSelectionDialog(context);
    }
  }

  void _showPeriodSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: _isLightTheme
                  ? const Color.fromRGBO(10, 23, 42, 1)
                  : const Color.fromRGBO(255, 255, 240, 1),
              title: const Text('Select Period'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Selected Date: ${_formatJalaliDate(_selectedDate)}'
                        : 'Select Date',
                  ),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.grey,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>['Week', 'Month']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: periodController,
                    decoration: const InputDecoration(
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 2)),
                      hintText: "مدت ثبت نام",
                    ),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Save'),
// Inside your onPressed function in the save button

                  onPressed: () async {
                    if (_selectedDate != null &&
                        periodController.text.isNotEmpty) {
                      int periods = int.tryParse(periodController.text) ?? 1;

// Update the start date in Firestore
                      _updatePlayerInfo('Date', {
                        'year': _selectedDate!.year,
                        'month': _selectedDate!.month,
                        'day': _selectedDate!.day,
                      });

// Initialize endDate with the selected date
                      Jalali endDate = _selectedDate!;

// Calculate the end date based on the selected period
                      if (dropdownValue == 'Week') {
                        endDate = _selectedDate!.addDays(periods * 7);
                      } else {
                        endDate = _selectedDate!.addDays(periods * 30);
                      }

// Update the end date in Firestore
                      _updatePlayerInfo('End Date', {
                        'year': endDate.year,
                        'month': endDate.month,
                        'day': endDate.day,
                      });
// Retrieve the player's documentId from Firestore using name and last name
                      QuerySnapshot playerSnapshot = await FirebaseFirestore
                          .instance
                          .collection('players')
                          .where('Name', isEqualTo: widget.data['Name'])
                          .where('Last Name',
                              isEqualTo: widget.data['Last Name'])
                          .get();

                      if (playerSnapshot.docs.isNotEmpty) {
// Assuming there is only one document with this name and last name
                        String documentId = playerSnapshot.docs.first.id;

// Now you can update the Period using this documentId
                        CollectionReference collection =
                            FirebaseFirestore.instance.collection('players');
                        try {
                          await collection.doc(documentId).update({
                            'Period': periods,
                          });
                          print('Period updated successfully');
                        } catch (e) {
                          print('Failed to update Period: $e');
                        }
                      } else {
                        print('Error: Player not found');
                      }
                      Navigator.of(context).pop();
                    } else {
                      print("Error: Date or period is not selected");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatJalaliDate(Jalali? date) {
    if (date == null) return 'No Date';
    return '${date.year}/${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اطلاعات بازیکن',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "TrajanPro",
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'نام', nameController, 'Name',
                        widget.data['Name']);
                  },
                  child:
                      buildPlayerInfoBox(context, 'نام', widget.data['Name']),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'فامیلی', lastController,
                        'Last Name', widget.data['Last Name']);
                  },
                  child: buildPlayerInfoBox(
                      context, 'فامیلی', widget.data['Last Name']),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setStateDialog) {
                          return AlertDialog(
                            backgroundColor: _isLightTheme
                                ? const Color.fromRGBO(10, 23, 42, 1)
                                : const Color.fromRGBO(255, 255, 240, 1),
                            title: const Text('انتخاب رده سنی'),
                            content: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : const Color(0xFF1E1E2C),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(255, 180, 0, 1.0),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    dropdownColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : const Color(0xFF1E1E2C),
                                    value: _selectedType,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color.fromRGBO(255, 180, 0, 1.0),
                                        size: 28),
                                    elevation: 12,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                    hint: const Text(
                                      'انتخاب رده سنی',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    onChanged: (String? newValue) {
                                      setStateDialog(() {
                                        _selectedType = newValue;
                                      });
                                    },
                                    items: _typeOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('لغو'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: const Text('ثبت'),
                                onPressed: () {
                                  if (_selectedType != null) {
                                    _updatePlayerInfo('Type', _selectedType);
                                    Navigator.of(context).pop();
                                  } else {
                                    print("Error: No type selected");
                                  }
                                },
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                  child: buildPlayerInfoBox(
                      context, 'رده سنی', widget.data['Type'] ?? 'نامشخص'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'فیس', lastController, 'Fee',
                        widget.data['Fee']);
                  },
                  child: buildPlayerInfoBox(
                      context, 'فیس', widget.data['Fee']?.toString() ?? '0'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'قرض', debtorController, 'Debt',
                        widget.data['Debt'].toString(),
                        isNumeric: true);
                  },
                  child: buildPlayerInfoBox(
                      context, 'قرض', widget.data['Debt'].toString()),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: buildPlayerInfoBox(
                    context,
                    'تاریخ ثبت نام',
                    _selectedDate != null
                        ? _formatJalaliDate(_selectedDate)
                        : _formatDate(widget.data['Date']),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
// Optional: Add functionality for end date selection if needed
                  },
                  child: buildPlayerInfoBox(
                    context,
                    'تاریخ پایان',
                    _formatDate(widget.data['End Date']),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.data.containsKey('userId') &&
                    widget.data['userId'] != null)
                  FutureBuilder<int>(
                    future: getAttendanceCount(widget.data['userId'], true),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return Text('Present Count: ${snapshot.data}');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                if (widget.data.containsKey('userId') &&
                    widget.data['userId'] != null)
                  FutureBuilder<int>(
                    future: getAttendanceCount(widget.data['userId'], false),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return Text('Absent Count: ${snapshot.data}');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget buildPlayerInfoBox(BuildContext context, String label, String value) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 300,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(255, 180, 0, 1.0),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 20, fontFamily: 'LilitaOne'),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(
            child: Container(
              width: 290,
              height: 60,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 180, 0, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 23),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(BuildContext context, String title,
      TextEditingController controller, String field, String initialValue,
      {bool isNumeric = false}) {
    if (field == 'Date') {
// Initialize the _selectedDate with the existing date from data if available
      if (widget.data['Date'] != null) {
        _selectedDate = Jalali(
          widget.data['Date']['year'],
          widget.data['Date']['month'],
          widget.data['Date']['day'],
        );
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: _isLightTheme
                ? const Color.fromRGBO(10, 23, 42, 1)
                : const Color.fromRGBO(255, 255, 240, 1),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: buildPlayerInfoBox(
                    context,
                    'تاریخ',
                    _selectedDate != null
                        ? _formatJalaliDate(_selectedDate)
                        : 'No Date',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _selectedPeriod = newValue;
                    }
                  },
                  items: <String>['Week', 'Month']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_selectedDate != null) {
                    Map<String, dynamic> dateMap = {
                      'year': _selectedDate!.year,
                      'month': _selectedDate!.month,
                      'day': _selectedDate!.day,
                      'period': _selectedPeriod,
                    };
                    if (kDebugMode) {
                      print("Saving Date with period: $_selectedPeriod");
                    }
                    _updatePlayerInfo(field, dateMap);
                    Navigator.of(context).pop();
                  } else {
                    print("Error: No date selected");
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      controller.text = initialValue;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: _isLightTheme
                ? const Color.fromRGBO(10, 23, 42, 1)
                : const Color.fromRGBO(255, 255, 240, 1),
            title: Text(title),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: title),
              keyboardType:
                  isNumeric ? TextInputType.number : TextInputType.text,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  print("Saving value: ${controller.text}");
                  _updatePlayerInfo(field, controller.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _updatePlayerInfo(String field, dynamic value) async {
    print("Updating field: $field with value: $value");

    String name = widget.data['Name'];
    String lastName = widget.data['Last Name'];

// Query to find the player in the players collection
    Query playerQuery = FirebaseFirestore.instance
        .collection('players')
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName);

// Query to find the player in the Debtors collection
    Query debtorQuery = FirebaseFirestore.instance
        .collection('Debtors')
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName);

    try {
// Update player info in 'players' collection
      QuerySnapshot playerSnapshot = await playerQuery.get();
      if (playerSnapshot.docs.isNotEmpty) {
        for (var doc in playerSnapshot.docs) {
          DocumentReference docRef = doc.reference;

// If updating the 'Debt' field
          if (field == 'Debt') {
            int debtValue = int.tryParse(value) ?? 0; // Convert value to int
            await docRef.update({field: debtValue});

// Handle updating 'Debtors' collection
            if (debtValue > 0) {
// Check if player exists in 'Debtors'
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
// Player exists in 'Debtors', update the debt
                for (var debtorDoc in debtorSnapshot.docs) {
                  DocumentReference debtorDocRef = debtorDoc.reference;
                  await debtorDocRef.update({'Debt': debtValue});
                  print("Player's debt updated in Debtors: $debtValue");
                }
              } else {
// Player does not exist in 'Debtors', add them
                await FirebaseFirestore.instance.collection('Debtors').add({
                  'Name': name,
                  'Last Name': lastName,
                  'Debt': debtValue,
                });
                print("Player added to Debtors with debt: $debtValue");
              }
            } else {
// Remove player from 'Debtors' if debt is 0 or less
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
                for (var debtorDoc in debtorSnapshot.docs) {
                  await debtorDoc.reference.delete();
                  print("Player removed from Debtors as debt is cleared.");
                }
              }
            }
          } else if (field == 'Date') {
// Ensure value is a Map for date fields
            if (value is Map<String, dynamic>) {
              await docRef.update({field: value});
            } else {
              print(
                  "Error: Value for Date field is not a Map<String, dynamic>");
            }
          } else {
            await docRef.update({field: value});
          }

          print("$field updated successfully in players collection.");
        }
      } else {
        print("No player found for update in players collection!");
      }
    } catch (error) {
      print("Error updating document: $error");
    }
  }
}
