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
      body: SizedBox(
        height: fullScreenHeight,
        width: fullScreenWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Name",
                ),
              ),
              TextField(
                controller: lastController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Last Name",
                ),
              ),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Fee",
                ),
              ),
              TextField(
                controller: periodController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  hintText: "Period",
                ),
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

    if (debtorController.text.isEmpty) {
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
    else if (debtorController.text.isNotEmpty) {
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

    try {
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('Deptors');

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

    debtorController.clear();
    lastController.clear();
    nameController.clear();
    periodController.clear();
    debtorController.clear();
    feeController.clear();
  }
}
