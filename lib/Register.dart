import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController debtorController = TextEditingController();
  String dropdownValue = 'Week';
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
// backgroundColor: _isLightTheme ? const Color.fromRGBO(255, 255, 240, 1) : const Color.fromRGBO(10, 23, 42,1),
      body: Container(
        height: fullScreenHeight,
        width: fullScreenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/pic/backgroundR.jpg"),fit: BoxFit.cover)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Name",
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: lastController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Last Name",
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Fee",
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: fullScreenWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
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
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: periodController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Period",
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: debtorController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Debtors",
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: fullScreenWidth,
                child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: const ButtonStyle(),
                  child: const Text("Select Date"),
                ),
              ),
              SizedBox(
                width: fullScreenWidth,
                child: ElevatedButton(
                  onPressed: () {
                    createRecord();
                  },
                  style: const ButtonStyle(),
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createRecord() async {
    var selDate = [
      _selectedDate?.year,
      _selectedDate?.month,
      _selectedDate?.day
    ];
    int proid = int.parse(periodController.text);
    proid = dropdownValue == 'Week' ? proid * 7 : proid * 30;
    DateTime? endDate = _selectedDate?.add(Duration(days: proid));
    print('The proid will end on: ${endDate.toString()}');
    if (debtorController.text == "0" || debtorController.text.isEmpty) {
      try {
        CollectionReference collRef =
            FirebaseFirestore.instance.collection('players');
        await collRef.add({
          'Name': nameController.text,
          'Last Name': lastController.text,
          'Fee': feeController.text,
          'Period': periodController.text,
          'Debt': debtorController.text, // Use the modified debtValue here
          'Date': selDate,
          'End Date': endDate.toString(),
        }).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successful inserted'),
            ),
          );
        }).catchError((error) {
          print("Failed to add user: $error");
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add user'),
          ),
        );
      }
    } else if (debtorController.text.isNotEmpty) {
      try {
        CollectionReference collRef =
            FirebaseFirestore.instance.collection('players');
        await collRef.add({
          'Name': nameController.text,
          'Last Name': lastController.text,
          'Fee': feeController.text,
          'Period': periodController.text,
          'Debt': debtorController.text, // Use the modified debtValue here
          'Date': selDate,
          'End Date': endDate.toString(),
        }).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successful inserted'),
            ),
          );
        }).catchError((error) {
          print("Failed to add user: $error");
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add user'),
          ),
        );
      }
      try {
        CollectionReference collRef =
            FirebaseFirestore.instance.collection('Debtors');
        await collRef.add({
          'Name': nameController.text,
          'Last Name': lastController.text,
          'Debt': debtorController.text, // Use the modified debtValue here
        }).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successful inserted'),
            ),
          );
        }).catchError((error) {
          print("Failed to add user: $error");
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add user'),
          ),
        );
      }
    }
  }
}
