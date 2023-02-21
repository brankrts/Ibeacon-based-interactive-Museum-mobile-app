import 'package:beacons_plugin_example/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/index_controller.dart';
import 'start_screen.dart';

// ignore: must_be_immutable
class ResultPage extends StatelessWidget {
  ResultPage({required this.marksEarnedFromQuiz});

  int marksEarnedFromQuiz = 0;
  addFirestore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("scoreId")) {
      String? scoreId = prefs.getString("scoreId");
      int? storedScore = prefs.getInt("score");

      await FirebaseFirestore.instance
          .collection('scores')
          .doc(scoreId)
          .update({"score": score + storedScore!});
      await prefs.setInt("score", score + storedScore);
    } else {
      await FirebaseFirestore.instance
          .collection('scores')
          .add({"score": score}).then((value) async {
        if (!(prefs.containsKey(value.id))) {
          await prefs.setString("scoreId", value.id);
          await prefs.setInt("score", score);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexController>(
        builder: (context, getIndexProvider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: marksEarnedFromQuiz > 4
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              insetPadding: EdgeInsets.zero,
                              contentTextStyle: GoogleFonts.mulish(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Tekrar ?',
                              ),
                              content: const Text(
                                'Quize baştan başlamak istediğine\nemin misin?',
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text(
                                    'Hayır',
                                    style: TextStyle(
                                        color: Color.fromRGBO(66, 130, 241, 1)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen())),
                                  child: const Text(
                                    'Evet',
                                    style: TextStyle(
                                        color: Color.fromRGBO(66, 130, 241, 1)),
                                  ),
                                ),
                              ],
                            ));
                  },
                )
              : const SizedBox(),
          centerTitle: true,
          title: Text(
            'Sonuç',
            style: GoogleFonts.mulish(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 149.33,
                  height: 149.33,
                  child: CircularPercentIndicator(
                    backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
                    animation: true,
                    radius: 70,
                    lineWidth: 13.0,
                    percent: marksEarnedFromQuiz / 10,
                    animationDuration: 1000,
                    reverse: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text(
                      "$marksEarnedFromQuiz/10",
                      style: GoogleFonts.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        fontSize: 15,
                      ),
                    ),
                    progressColor: marksEarnedFromQuiz > 4
                        ? const Color.fromRGBO(82, 186, 0, 1)
                        : const Color.fromRGBO(254, 123, 30, 1),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    marksEarnedFromQuiz < 5
                        ? Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(254, 123, 30, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Fena değildi...!',
                                style: GoogleFonts.mulish(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(82, 186, 0, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                                child: Text(
                              'Harika!',
                              style: GoogleFonts.mulish(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                fontSize: 15,
                              ),
                            )),
                          ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    marksEarnedFromQuiz < 5
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 23,
                            ),
                            child: Container(
                              width: 160,
                              height: 37,
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()));
                                },
                                child: Text(
                                  'Tekrar Dene',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.mulish(
                                    decoration: TextDecoration.underline,
                                    color:
                                        const Color.fromRGBO(66, 130, 241, 1),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              top: 23,
                            ),
                            child: Container(
                              width: 160,
                              height: 60,
                              color: Colors.white,
                              child: Text(
                                'Tebrikler\n Quiz başarılı',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.mulish(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                  ],
                )
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await addFirestore(marksEarnedFromQuiz * 10);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              child: Text("Skoru Kaydet"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange[700])),
            )
          ],
        ),
      );
    });
  }
}
