import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlayerList extends StatefulWidget {
  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final CollectionReference playersRef =
  FirebaseFirestore.instance.collection('players');
  final CollectionReference debtorsRef =
  FirebaseFirestore.instance.collection('Debtors');
  String searchString = '';

  final TextEditingController _searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchString = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search...",
            icon: IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  searchString = '';
                });
              },
              icon: Icon(Icons.clear_sharp, color: Colors.white),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchString == null || searchString.trim() == '')
            ? playersRef.snapshots()
            : playersRef
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
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              var date = data['Date'];
              String dateString = '';
              if (date is List) {
                dateString = date.join(',') != 'null,null,null'
                    ? date.join(',')
                    : '';
              } else {
                dateString = date != 'null,null,null' ? date : '';
              }
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
                  leading: CircleAvatar(
                    child: Text(data['End Date'].toString()),
                  ),
                  subtitle: Text(dateString),
                  trailing: Text(data['Debt']),
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
