import 'package:beacons_plugin_example/models/esermodel.dart';
import 'package:beacons_plugin_example/models/sorumodel.dart';
import 'package:beacons_plugin_example/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Deneme extends StatefulWidget {
  Deneme({Key? key}) : super(key: key);

  @override
  State<Deneme> createState() => _DenemeState();
}

class _DenemeState extends State<Deneme> {
  late List<Eser> eserler;
  late FirebaseService service;
  List<String> optionone = <String>[];
  List<String> optiontwo = <String>[];
  List<String> optiontree = <String>[];
  List<String> optionfour = <String>[];
  List<String> questions = <String>[];
  List<int> answers = <int>[];

  Future<List<Soru>> getSorular() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('sorular').get();

    snapshot.docs.forEach((element) {
      optionone.add(element.data()["a"]);
      optiontwo.add(element.data()["b"]);
      optiontree.add(element.data()["c"]);
      optionfour.add(element.data()["d"]);
      questions.add(element.data()["soru"]);
      answers.add(element.data()["cevap"]);
    });

    return snapshot.docs
        .map((docSnapshot) => Soru.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    getSorular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deneme'),
      ),
      body: FutureBuilder(
        future: getSorular(),
        builder: (context, AsyncSnapshot<List<Soru>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              print(answers[2]);
              return Text("Text");
            } else {
              return Text("No data");
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            throw "Bağlanılamadı";
          }
        },
      ),
    );
  }
}
