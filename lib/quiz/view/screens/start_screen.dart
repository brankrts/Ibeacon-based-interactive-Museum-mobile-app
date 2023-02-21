import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/index_controller.dart';
import 'home_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String myCore = "0";
  List<int> scoreTable = [];

  getFromLocalDb() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("score")) {
      setState(() {
        myCore = prefs.getInt("score").toString();
      });
    }
  }

  getScoresFromFirebase() async {
    await FirebaseFirestore.instance.collection("scores").get().then((value) {
      value.docs.forEach((element) {
        if (!(scoreTable.contains(element.data()["score"]))) {
          scoreTable.add(element.data()["score"]);
        }
      });
    });
    scoreTable.sort((b, a) => a.compareTo(b));
  }

  @override
  void initState() {
    getFromLocalDb();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexController>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset('Assets/logo_quiz_app.png')),
              FutureBuilder(
                future: getScoresFromFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birinci   : ' +
                              (scoreTable.length > 0
                                  ? scoreTable[0].toString()
                                  : " "),
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(66, 130, 241, 1),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'İkinci     : ' +
                              (scoreTable.length > 0
                                  ? scoreTable[1].toString()
                                  : " "),
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(66, 130, 241, 1),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Üçüncü : ' +
                              (scoreTable.length > 0
                                  ? scoreTable[2].toString()
                                  : " "),
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(66, 130, 241, 1),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Güncel Skorum ' + myCore,
                          style: GoogleFonts.mulish(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 52, 72, 107),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Sıralama : ' +
                              (scoreTable.indexOf(int.parse(myCore)) + 1)
                                  .toString(),
                          style: GoogleFonts.mulish(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 52, 72, 107),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    throw "Firebaseden veriler alınamadı";
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  provider.restartIndexForQuestion();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => FirstPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Quize Başla',
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(66, 130, 241, 1),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
