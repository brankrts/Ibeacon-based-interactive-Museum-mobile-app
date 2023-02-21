import 'package:cloud_firestore/cloud_firestore.dart';

class Soru {
  late String kategori;
  late String soru;
  late String a;
  late String b;
  late String c;
  late String d;
  late int cevap;

  Soru(
      {required this.kategori,
      required this.a,
      required this.b,
      required this.c,
      required this.d,
      required this.cevap,
      required this.soru});

  Soru.fromJson(Map<String, dynamic> json) {
    kategori = json['kategori'];
    a = json['a'];
    b = json['b'];
    c = json['c'];
    d = json['d'];
    soru = json["soru"];
    cevap = json['cevap'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kategori'] = this.kategori;
    data['a'] = this.a;
    data['b'] = this.b;
    data['c'] = this.c;
    data['d'] = this.d;
    data['cevap'] = this.cevap;
    data['soru'] = this.soru;
    return data;
  }

  factory Soru.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return Soru(
      kategori: doc.data()!["kategori"],
      a: doc.data()!["a"],
      b: doc.data()!["b"],
      c: doc.data()!["c"],
      d: doc.data()!["d"],
      cevap: doc.data()!["cevap"],
      soru: doc.data()!["soru"],
    );
  }
}
