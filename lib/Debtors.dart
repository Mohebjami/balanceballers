import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Debtors extends StatefulWidget {
  @override
  _DebtorsState createState() => _DebtorsState();
}

class _DebtorsState extends State<Debtors> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Deptors');
  String searchString = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchString = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search...",
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchString == null || searchString.trim() == '')
            ? collectionRef.snapshots()
            : collectionRef
                .where('Name', isGreaterThanOrEqualTo: searchString)
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return ListView(
            children: snapshot.data?.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  return Slidable(
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
                      title: Text(data['Name']),
                      leading: Text(data['Last Name']),
                      trailing: Text(data['Debt']),
                      // Add other fields as needed
                    ),
                  );
                }).toList() ??
                [],
          );
        },
      ),
    );
  }
}
