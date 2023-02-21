import 'package:cloud_firestore/cloud_firestore.dart';

class Eser {
  late String title;
  late String description;
  late List<dynamic> images;

  Eser({required this.title, required this.description, required this.images});

  Eser.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['images'] = this.images;
    return data;
  }

  factory Eser.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return Eser(
        title: doc.data()!["title"],
        description: doc.data()!["description"],
        images: doc.data()!["images"]);
  }
}
