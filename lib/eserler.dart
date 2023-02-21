import 'package:beacons_plugin_example/details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tcard/tcard.dart';

import 'models/esermodel.dart';

class Eserler extends StatefulWidget {
  @override
  _EserlerState createState() => _EserlerState();
}

class _EserlerState extends State<Eserler> {
  TCardController _controller = TCardController();
  late List<Eser> eserler = <Eser>[];
  @override
  void initState() {
    super.initState();
    getEserler();
  }

  Future<List<Eser>> getEserler() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('eserler').get();

    return snapshot.docs
        .map((docSnapshot) => Eser.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
            child: FutureBuilder(
          future: getEserler(),
          builder: (context, AsyncSnapshot<List<Eser>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TCard(
                      cards: List.generate(
                        snapshot.data!.length,
                        (int index) {
                          return Builder(builder: (context) {
                            return SingleChildScrollView(
                              child: Card(
                                  elevation: 4.0,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                            snapshot.data![index].title
                                                .split(" ")[0],
                                            style: GoogleFonts.mulish(
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromRGBO(
                                                  66, 130, 241, 1),
                                            )),
                                        subtitle:
                                            Text(snapshot.data![index].title,
                                                style: GoogleFonts.mulish(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color.fromRGBO(177, 177, 180, 1),
                                                )),
                                        trailing: Icon(Icons.museum_outlined),
                                      ),
                                      Container(
                                        height: 300.0,
                                        child: Ink.image(
                                          image: NetworkImage(
                                              snapshot.data![index].images[0]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        child: Text(
                                            snapshot.data![index].description,
                                            maxLines: 5,
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                wordSpacing: 1)),
                                      ),
                                      TextButton(
                                        child: Text('Daha Fazla',
                                            style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue,
                                                fontSize: 15,
                                                wordSpacing: 1)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                    info:
                                                        snapshot.data![index])),
                                          );
                                        },
                                      )
                                    ],
                                  )),
                            );
                            ;
                          });
                        },
                      ),
                      size: Size(360, 600),
                      controller: _controller,
                      slideSpeed: 20,
                      onEnd: () {
                        _controller.reset();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            print(_controller);
                            _controller.back();
                          },
                          child: Text('Geri'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _controller.reset();
                          },
                          child: Text('Sıfırla'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _controller.forward();
                          },
                          child: Text('İleri'),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                throw "Has no data ";
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              throw "null";
            }
          },
        )),
      ),
    );
  }
}
