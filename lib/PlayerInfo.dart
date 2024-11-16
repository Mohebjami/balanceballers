// ignore: file_names
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

// ignore: must_be_immutable
class PlayerInfo extends StatelessWidget {
  final Map data;
  PlayerInfo({super.key, required this.data});

  Future<int> getAttendanceCount(String userId, bool isPresent) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .where('userId', isEqualTo: userId)
        .where('isPresent', isEqualTo: isPresent)
        .get();
    return querySnapshot.docs.length;
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
                          .where('Name', isEqualTo: data['Name'])
                          .where('Last Name', isEqualTo: data['Last Name'])
                          .get();

                      if (playerSnapshot.docs.isNotEmpty) {
                        String documentId = playerSnapshot.docs.first.id;

                        CollectionReference collection =
                            FirebaseFirestore.instance.collection('players');
                        try {
                          await collection.doc(documentId).update({
                            'Period': periods,
                          });
                          // print('Period updated successfully');
                        } catch (e) {
                          // print('Failed to update Period: $e');
                        }
                      } else {
                        // print('Error: Player not found');
                      }
                      Navigator.of(context).pop();
                    } else {
                      // print("Error: Date or period is not selected");
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
                    _showUpdateDialog(
                        context, 'نام', nameController, 'Name', data['Name']);
                  },
                  child: buildPlayerInfoBox(context, 'نام', data['Name']),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'فامیلی', lastController,
                        'Last Name', data['Last Name']);
                  },
                  child:
                      buildPlayerInfoBox(context, 'فامیلی', data['Last Name']),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(
                        context, 'فیس', lastController, 'Fee', data['Fee']);
                  },
                  child: buildPlayerInfoBox(context, 'فیس', data['Fee']),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showUpdateDialog(context, 'قرض', debtorController, 'Debt',
                        data['Debt'].toString(),
                        isNumeric: true);
                  },
                  child: buildPlayerInfoBox(
                      context, 'قرض', data['Debt'].toString()),
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
                        : _formatDate(data['Date']),
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
                    _formatDate(data['End Date']),
                  ),
                ),
                const SizedBox(height: 20),
                if (data.containsKey('userId') && data['userId'] != null)
                  FutureBuilder<int>(
                    future: getAttendanceCount(data['userId'], true),
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
                if (data.containsKey('userId') && data['userId'] != null)
                  FutureBuilder<int>(
                    future: getAttendanceCount(data['userId'], false),
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
      if (data['Date'] != null) {
        _selectedDate = Jalali(
          data['Date']['year'],
          data['Date']['month'],
          data['Date']['day'],
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
                    _updatePlayerInfo(field, dateMap);
                    Navigator.of(context).pop();
                  } else {
                    // print("Error: No date selected");
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
    String name = data['Name'];
    String lastName = data['Last Name'];

    Query playerQuery = FirebaseFirestore.instance
        .collection('players')
        .where('Name', isEqualTo: name)
        .where('Last Name', isEqualTo: lastName);

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
          if (field == 'Debt') {
            int debtValue = int.tryParse(value) ?? 0;
            await docRef.update({field: debtValue});

            if (debtValue > 0) {
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
                for (var debtorDoc in debtorSnapshot.docs) {
                  DocumentReference debtorDocRef = debtorDoc.reference;
                  await debtorDocRef.update({'Debt': debtValue});
                }
              } else {
                await FirebaseFirestore.instance.collection('Debtors').add({
                  'Name': name,
                  'Last Name': lastName,
                  'Debt': debtValue,
                });
              }
            } else {
              QuerySnapshot debtorSnapshot = await debtorQuery.get();
              if (debtorSnapshot.docs.isNotEmpty) {
                for (var debtorDoc in debtorSnapshot.docs) {
                  await debtorDoc.reference.delete();
                }
              }
            }
          } else if (field == 'Date') {
            if (value is Map<String, dynamic>) {
              await docRef.update({field: value});
            } else {
              // print(
              //     "Error: Value for Date field is not a Map<String, dynamic>");
            }
          } else {
            await docRef.update({field: value});
          }
          // print("$field updated successfully in players collection.");
        }
      } else {
        // print("No player found for update in players collection!");
      }
    } catch (error) {
      // print("Error updating document: $error");
    }
  }
}
