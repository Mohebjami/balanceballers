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

  Color coYellow = const Color.fromRGBO(255, 180, 0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debtors",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "TrajanPro",
            fontWeight: FontWeight.bold),),
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
                labelText: "Search",
                hintText: "Search",
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
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: snapshot.data?.docs.asMap().entries.map((entry) {
                      int index = entry.key;
                      DocumentSnapshot document = entry.value;
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return Card(
                        color: coYellow,
                        child: Slidable(
                          closeOnScroll: true,
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                backgroundColor: Colors.red,
                                icon: Icons.check,
                                label: 'Delete',
                                onPressed: (context) async {
                                  await FirebaseFirestore.instance.runTransaction(
                                          (Transaction myTransaction) async {
                                        await myTransaction.delete(document.reference);
                                      });
                                },
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(data['Name'], style: const TextStyle(color: Colors.white,fontSize: 20),),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.person , color: Colors.white,),
                            ),
                            trailing: Text(data['Debt'], style: const TextStyle(color: Colors.white,fontSize: 20),),
                            subtitle: Text(data['Last Name'], style: const TextStyle(color: Colors.white,fontSize: 20),),
                            // Add other fields as needed
                          ),
                        ),
                      );
                    }).toList() ?? [],
                  ),
                );

              },
            ),
          ),

        ],
      ),
    );
  }
}
