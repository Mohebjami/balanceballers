import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar:  AppBar(
        title: const Text("Free Player",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),),
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
                          image: DecorationImage(image: AssetImage("assets/pic/ball.png"))
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: "Name",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: lastController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                        hintText: "Last Name",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                            left: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                            right: BorderSide(
                              width: 1.0,
                              color:Colors.grey,
                            ),
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "Select a Date",
                                textAlign: TextAlign.center,
                                // style: TextStyle(color: Color(0xFF000000))
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: fullScreenWidth,
                      child: MaterialButton(
                        onPressed: () {
                          createRecord();
                        },
                        color: const Color.fromRGBO(255, 180, 0, 1.0),
                        child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize:20),),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ],
            ),
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
