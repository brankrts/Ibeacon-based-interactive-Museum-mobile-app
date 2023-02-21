import 'package:beacons_plugin_example/models/esermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<Eser>> getEserler() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _fireStore.collection('eserler').get();

    return snapshot.docs
        .map((docSnapshot) => Eser.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<void> getSorular() async {
    QuerySnapshot querySnapshot = await _fireStore.collection('sorular').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);
  }

  Future<void> getMuze() async {
    QuerySnapshot querySnapshot = await _fireStore.collection('amasra').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(allData);
  }
}
