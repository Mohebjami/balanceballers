import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Free_Player extends StatefulWidget {
  const Free_Player({super.key});

  @override
  State<Free_Player> createState() => _Free_PlayerState();
}

class _Free_PlayerState extends State<Free_Player> {


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

  TextEditingController nameController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController periodController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        width: fullScreenWidth,
        height: fullScreenHeight,
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

  void createRecord() async{
    var selDate = [
      _selectedDate?.year,
      _selectedDate?.month,
      _selectedDate?.day
    ];
    try {
      CollectionReference collRef =
      FirebaseFirestore.instance.collection('Free_Player');

      await collRef.add({
        'Name': nameController.text,
        'Last Name': lastController.text,
        'Date':selDate,
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
