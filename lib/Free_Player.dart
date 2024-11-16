// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart' as pdp;

// ignore: camel_case_types
class Free_Player extends StatefulWidget {
  const Free_Player({super.key});

  @override
  State<Free_Player> createState() => _Free_PlayerState();
}

// ignore: camel_case_types
class _Free_PlayerState extends State<Free_Player> {
  pdp.Jalali? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final pdp.Jalali? picked = await pdp.showPersianDatePicker(
      context: context,
      initialDate: pdp.Jalali.now(),
      firstDate: pdp.Jalali(1400, 1),
      lastDate: pdp.Jalali(1450, 12),
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
      appBar: AppBar(
        title: const Text(
          "بازیکنان رایگان",
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
      body: SingleChildScrollView(
        child: SizedBox(
          width: fullScreenWidth,
          height: fullScreenHeight,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/pic/ball.png"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: "نام",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: lastController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: "فامیلی",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1.0, color: Colors.grey),
                          left: BorderSide(width: 1.0, color: Colors.grey),
                          right: BorderSide(width: 1.0, color: Colors.grey),
                          bottom: BorderSide(width: 1.0, color: Colors.grey),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                _selectedDate != null
                                    ? _selectedDate!.formatFullDate()
                                    : "تاریخ",
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              tooltip: 'Tap to open date picker',
                              onPressed: () => _selectDate(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: fullScreenWidth,
                      child: MaterialButton(
                        onPressed: () {
                          createRecord();
                        },
                        color: const Color.fromRGBO(255, 180, 0, 1.0),
                        child: const Text("ذخیره", style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
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

    try {
      CollectionReference collRef = FirebaseFirestore.instance.collection('Free_Player');
      await collRef.add({
        'Name': nameController.text,
        'Last Name': lastController.text,
        'Date': selDate,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('موفقانه ذخیره شد'),
          ),
        );
      }).catchError((error) {
        // print("Failed to add user: $error");
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
