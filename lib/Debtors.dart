import 'package:balanceballers/PlayerInfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Debtors extends StatefulWidget {
  @override
  _DebtorsState createState() => _DebtorsState();
}

class _DebtorsState extends State<Debtors> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Debtors');
  String searchString = '';

  TextEditingController Dept = TextEditingController();

  Color coYellow = const Color.fromRGBO(255, 180, 0, 1.0);
  bool _isLightTheme = false; // Declare _isLightTheme

  bool get isLightTheme => _isLightTheme; // Getter for _isLightTheme

  set isLightTheme(bool value) {
    _isLightTheme = value;
  }

  Map<String, String?>? selectedPlayer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWaitingData();
  }

  List<Map<String, String?>> PalyerDropDown = [];

  Future<List<Map<String, String?>>> showPlayersDropDownDebt() async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('players');
    var snapshots = await collectionReference.get();
    return snapshots.docs
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'Name': data['Name'] as String?,
            'Last Name': data['Last Name'] as String?,
          };
        })
        .where((item) => item['Name'] != null && item['Last Name'] != null)
        .toList();
  }

  Future<void> fetchWaitingData() async {
    PalyerDropDown = await showPlayersDropDownDebt();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double fullScreenHeight = MediaQuery.of(context).size.height;
    double fullScreenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "قرض دار ها",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? collectionRef.snapshots()
                  : collectionRef
                      .where('Name', isGreaterThanOrEqualTo: searchString)
                      .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: snapshot.data?.docs.asMap().entries.map((entry) {
                          int index = entry.key;
                          DocumentSnapshot document = entry.value;
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          return Card(
                            color: coYellow,
                            child: Slidable(
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
                                          .runTransaction((Transaction
                                              myTransaction) async {
                                        await myTransaction
                                            .delete(document.reference);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  data['Name'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: Text(
                                  data['Debt'].toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                subtitle: Text(
                                  data['Last Name'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
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
                          );
                        }).toList() ??
                        [],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContextcontext) {
                return AlertDialog(
                  backgroundColor: _isLightTheme
                      ? const Color.fromRGBO(10, 23, 42, 1)
                      : const Color.fromRGBO(255, 255, 240, 1),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextField(
                                controller: Dept,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2)),
                                  hintText: "قرض",
                                  hintStyle: TextStyle(color: Colors.black),
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(255, 180, 0, 1.0),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                      bottom: 5.0,
                                      top: 5.0),
                                  child: DropdownButton<Map<String, String?>>(
                                    value: selectedPlayer,
                                    hint: const Center(
                                      child: Text(
                                        "انتخاب بازیکن",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    focusColor: Colors.white,
                                    iconEnabledColor: Colors.white,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.white,
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: const TextStyle(color: Colors.white),
                                    dropdownColor:
                                        const Color.fromRGBO(255, 180, 0, 1.0),
                                    underline: Container(
                                      color: Colors.transparent,
                                    ),
                                    onChanged:
                                        (Map<String, String?>? newValue) {
                                      setState(() {
                                        selectedPlayer = newValue;
                                      });
                                      print("${selectedPlayer}");
                                    },
                                    items: PalyerDropDown.map<
                                            DropdownMenuItem<
                                                Map<String, String?>>>(
                                        (Map<String, String?> value) {
                                      return DropdownMenuItem<
                                          Map<String, String?>>(
                                        alignment: Alignment.centerRight,
                                        value: value,
                                        child: Text(value['Name']! +
                                            ' ' +
                                            value['Last Name']!),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 50,
                                width: fullScreenWidth,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    int dbt = int.parse(Dept.text);
                                    CollectionReference collRef =
                                        FirebaseFirestore.instance
                                            .collection('Debtors');
                                    // First, check if the data already exists in the Debtors table
                                    Query query = collRef
                                        .where('Name',
                                            isEqualTo: selectedPlayer?['Name'])
                                        .where('Last Name',
                                            isEqualTo:
                                                selectedPlayer?['Last Name']);
                                    query.get().then((querySnapshot) async {
                                      if (querySnapshot.docs.isNotEmpty) {
                                        // If the data exists, just update the Debt column
                                        for (var doc in querySnapshot.docs) {
                                          DocumentReference docRef =
                                              doc.reference;
                                          await docRef.update({'Debt': dbt});
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        // If the data does not exist, insert the data and update the Players table
                                        await collRef.add({
                                          'Name': selectedPlayer?['Name'],
                                          'Last Name':
                                              selectedPlayer?['Last Name'],
                                          'Debt': dbt,
                                        }).then((value) async {
                                          Query query = FirebaseFirestore
                                              .instance
                                              .collection('players')
                                              .where('Name',
                                                  isEqualTo:
                                                      selectedPlayer?['Name'])
                                              .where('Last Name',
                                                  isEqualTo: selectedPlayer?[
                                                      'Last Name']);
                                          query
                                              .get()
                                              .then((querySnapshot) async {
                                            if (querySnapshot.docs.isNotEmpty) {
                                              for (var doc
                                                  in querySnapshot.docs) {
                                                DocumentReference docRef =
                                                    doc.reference;
                                                await docRef
                                                    .update({'Debt': dbt});
                                                Navigator.of(context).pop();
                                              }
                                            } else {
                                              print("No such document!");
                                            }
                                          }).catchError((error) {
                                            print(
                                                "Error getting document: $error");
                                          });
                                        }).catchError((error) {
                                          print(
                                              "Failed to update user: $error");
                                        });
                                      }
                                    }).catchError((error) {
                                      print("Error getting document: $error");
                                    });
                                  },
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(255, 180, 0, 1.0),
                                  )),
                                  child: const Text(
                                    "ذخیره",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: "TrajanPro",
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
