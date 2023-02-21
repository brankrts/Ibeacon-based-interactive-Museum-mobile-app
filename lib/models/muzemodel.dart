import 'package:cloud_firestore/cloud_firestore.dart';

class Muze {
  late String adress;
  late String description;
  late List<dynamic> images;
  late String telno;

  Muze(
      {required this.adress,
      required this.description,
      required this.images,
      required this.telno});

  Muze.fromJson(Map<String, dynamic> json) {
    adress = json['adress'];
    description = json['description'];
    images = json['images'].cast<String>();
    telno = json['telno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adress'] = this.adress;
    data['description'] = this.description;
    data['images'] = this.images;
    data['telno'] = this.telno;
    return data;
  }

  factory Muze.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return Muze(
        adress: doc.data()!["adress"],
        description: doc.data()!["description"],
        images: doc.data()!["images"],
        telno: doc.data()!["telno"]);
  }
}
