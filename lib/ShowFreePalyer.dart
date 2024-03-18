import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class ShowFreePlayer extends StatelessWidget {
  Future<List<DocumentSnapshot>> getData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore.collection('Free_Player').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Free Players',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "TrajanPro",
              fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromRGBO(255, 180, 0, 1.0),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromRGBO(255, 180, 0, 1.0),
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
                              await FirebaseFirestore.instance.collection('Free_Player').doc(doc.id).delete();
                              print("Deleted");
                            },
                          ),

                        ],
                      ),
                      child: ListTile(
                        title: Text(doc['Name'], style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                        subtitle: Text(doc['Last Name'], style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                        trailing: Text('${doc['Date'][0]}/${doc['Date'][1]}/${doc['Date'][2]}', style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                      ),

                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
