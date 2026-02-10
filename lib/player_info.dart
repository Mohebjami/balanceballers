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
  String? _selectedPeriod = 'Week';

  Future<void> _selectDate(BuildContext context) async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedDate ?? Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1450),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
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
                  const SizedBox(height: 10),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: periodController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(width: 2),
                      ),
                      hintText: "مدت ثبت نام",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
                  ),
                  child: const Text('Save'),
                  onPressed: () async {
                    if (_selectedDate != null &&
                        periodController.text.isNotEmpty) {
                      int periods = int.tryParse(periodController.text) ?? 1;

                      _updatePlayerInfo('Date', {
                        'year': _selectedDate!.year,
                        'month': _selectedDate!.month,
                        'day': _selectedDate!.day,
                      });

                      Jalali endDate = _selectedDate!;
                      if (dropdownValue == 'Week') {
                        endDate = _selectedDate!.addDays(periods * 7);
                      } else {
                        endDate = _selectedDate!.addDays(periods * 30);
                      }

                      _updatePlayerInfo('End Date', {
                        'year': endDate.year,
                        'month': endDate.month,
                        'day': endDate.day,
                      });

                      QuerySnapshot playerSnapshot = await FirebaseFirestore
                          .instance
                          .collection('players')
                          .where('Name', isEqualTo: widget.data['Name'])
                          .where('Last Name',
                              isEqualTo: widget.data['Last Name'])
                          .get();

                      if (playerSnapshot.docs.isNotEmpty) {
                        String documentId = playerSnapshot.docs.first.id;
                        CollectionReference collection =
                            FirebaseFirestore.instance.collection('players');
                        try {
                          await collection.doc(documentId).update({
                            'Period': periods,
                          });
                        } catch (e) {
                          print('Failed to update Period: $e');
                        }
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
      ),
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildInteractiveBox(
                    context, 'نام', widget.data['Name'], nameController, 'Name'),
                const SizedBox(height: 16),
                buildInteractiveBox(context, 'فامیلی', widget.data['Last Name'],
                    lastController, 'Last Name'),
                const SizedBox(height: 16),
                buildTypeSelector(context),
                const SizedBox(height: 16),
                buildInteractiveBox(
                    context,
                    'فیس',
                    widget.data['Fee']?.toString() ?? '0',
                    feeController,
                    'Fee'),
                const SizedBox(height: 16),
                buildInteractiveBox(
                    context,
                    'قرض',
                    widget.data['Debt'].toString(),
                    debtorController,
                    'Debt',
                    isNumeric: true),
                const SizedBox(height: 16),
                buildDateSelector(context, 'تاریخ ثبت نام', _selectedDate,
                    widget.data['Date']),
                const SizedBox(height: 16),
                buildDateDisplay(
                    context, 'تاریخ پایان', widget.data['End Date']),
                const SizedBox(height: 20),
                if (widget.data.containsKey('userId') &&
                    widget.data['userId'] != null)
                  FutureBuilder<int>(
                    future: getAttendanceCount(widget.data['userId'], true),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Present Count: ${snapshot.data}',
                          style: const TextStyle(fontSize: 18),
                        );
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
                        return Text(
                          'Absent Count: ${snapshot.data}',
                          style: const TextStyle(fontSize: 18),
                        );
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

  // --- UI helpers ---
  Widget buildInteractiveBox(BuildContext context, String label, String value,
      TextEditingController controller, String field,
      {bool isNumeric = false}) {
    return GestureDetector(
      onTap: () {
        _showUpdateDialog(context, label, controller, field, value,
            isNumeric: isNumeric);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 180, 0, 1.0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 17, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTypeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return AlertDialog(
                  backgroundColor: _isLightTheme
                      ? const Color.fromRGBO(10, 23, 42, 1)
                      : const Color.fromRGBO(255, 255, 240, 1),
                  title: const Text('انتخاب رده سنی'),
                  content: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setStateDialog(() {
                        _selectedType = newValue;
                      });
                    },
                    items: _typeOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('لغو')),
                    ElevatedButton(
                        onPressed: () {
                          if (_selectedType != null) {
                            _updatePlayerInfo('Type', _selectedType);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('ثبت')),
                  ],
                );
              },
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 180, 0, 1.0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('رده سنی',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            Flexible(
              child: Text(_selectedType ?? 'نامشخص',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 17, color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateSelector(BuildContext context, String label, Jalali? date,
      Map<String, dynamic>? dateMap) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: buildInteractiveBox(
          context, label, date != null ? _formatJalaliDate(date) : _formatDate(dateMap),
          TextEditingController(), 'Date'),
    );
  }

  Widget buildDateDisplay(
      BuildContext context, String label, Map<String, dynamic>? dateMap) {
    return buildInteractiveBox(context, label, _formatDate(dateMap),
        TextEditingController(), 'End Date');
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

  void _showUpdateDialog(BuildContext context, String title,
      TextEditingController controller, String field, String initialValue,
      {bool isNumeric = false}) {
    if (field == 'Date') {
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

    Query playerQuery = FirebaseFirestore.instance
        .collection('players')
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName);

    Query debtorQuery = FirebaseFirestore.instance
        .collection('Debtors')
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName);

    try {
      QuerySnapshot playerSnapshot = await playerQuery.get();
           if (playerSnapshot.docs.isNotEmpty) {
        for (var doc in playerSnapshot.docs) {
          DocumentReference docRef = doc.reference;

          if (field == 'Debt') {
            int debtValue = int.tryParse(value.toString()) ?? 0;
            await docRef.update({field: debtValue});

            if (debtValue > 0) {
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
                for (var debtorDoc in debtorSnapshot.docs) {
                  await debtorDoc.reference.update({'Debt': debtValue});
                  print("Player's debt updated in Debtors: $debtValue");
                }
              } else {
                await FirebaseFirestore.instance.collection('Debtors').add({
                  'Name': name,
                  'Last Name': lastName,
                  'Debt': debtValue,
                });
                print("Player added to Debtors with debt: $debtValue");
              }
            } else {
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
                for (var debtorDoc in debtorSnapshot.docs) {
                  await debtorDoc.reference.delete();
                  print("Player removed from Debtors as debt is cleared.");
                }
              }
            }
          } else if (field == 'Date' || field == 'End Date') {
            if (value is Map<String, dynamic>) {
              await docRef.update({field: value});
            } else {
              print("Error: Value for $field is not a Map<String, dynamic>");
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
}