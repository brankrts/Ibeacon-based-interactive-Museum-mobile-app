import 'dart:math';

import 'package:beacons_plugin_example/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/sorumodel.dart';
import '../../controller/index_controller.dart';
import '../Widgets/choose_an_answer_box.dart';
import '../Widgets/option_box.dart';
import '../Widgets/question_answer_divider.dart';
import '../Widgets/question_box.dart';
import '../Widgets/question_mark_icon.dart';
import '../Widgets/question_number_index.dart';
import 'result_screen.dart';

class FirstPage extends StatefulWidget {
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<String> optionone = <String>[];
  List<String> optiontwo = <String>[];
  List<String> optiontree = <String>[];
  List<String> optionfour = <String>[];
  List<String> questions = <String>[];
  List<String> categories = <String>[];
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
      categories.add(element.data()["kategori"]);
    });
    var random = new Random();
    print(questions.length);
    for (var i = snapshot.docs.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = optionone[i];
      optionone[i] = optionone[n];
      optionone[n] = temp;

      var temp1 = optiontwo[i];
      optiontwo[i] = optiontwo[n];
      optiontwo[n] = temp1;

      var temp2 = optiontree[i];
      optiontree[i] = optiontree[n];
      optiontree[n] = temp2;
      var temp3 = optionfour[i];
      optionfour[i] = optionfour[n];
      optionfour[n] = temp3;
      var temp4 = questions[i];
      questions[i] = questions[n];
      questions[n] = temp4;
      var temp5 = answers[i];
      answers[i] = answers[n];
      answers[n] = temp5;
      var temp6 = categories[i];
      categories[i] = categories[n];
      categories[n] = temp6;
    }

    return snapshot.docs
        .map((docSnapshot) => Soru.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  int indexForQuestionNumber = 1;

  int selectedOption = 0;

  int marksObtainedFromCorrectAnswer = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSorular(),
      builder: (context, AsyncSnapshot<List<Soru>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                toolbarHeight: 78,
                backgroundColor: Colors.white,
                title: Text(
                  'Quiz',
                  style: GoogleFonts.mulish(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    letterSpacing: -0.3,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  //Main Column
                  children: [
                    Consumer<IndexController>(
                        builder: (context, provider, child) {
                      indexForQuestionNumber = provider.currentQuestionIndex;
                      selectedOption = provider.optionSelected;
                      return QuestionNumberIndex(
                        questionNumber: indexForQuestionNumber,
                      );
                    }),
                    Consumer<IndexController>(
                        builder: (context, provider, child) {
                      indexForQuestionNumber = provider.currentQuestionIndex;

                      return QuestionBox(
                        question: questions[indexForQuestionNumber],
                        category: categories[indexForQuestionNumber],
                      );
                    }),
                    const DividerToDivideQuestionAndAnswer(),
                    const QuestionMarkIcon(),
                    const ChooseAnAnswerBox(),
                    Consumer<IndexController>(
                        builder: (context, provider, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OptionBox(
                            optionSelected: provider.optionSelected,
                            optionParameter: optionone,
                            optionIndex: 'A.',
                            indexForQuestionNumber:
                                provider.currentQuestionIndex,
                            providerIndexForOption: 1,
                          ),
                          OptionBox(
                            optionSelected: provider.optionSelected,
                            optionParameter: optiontwo,
                            optionIndex: 'B.',
                            indexForQuestionNumber:
                                provider.currentQuestionIndex,
                            providerIndexForOption: 2,
                          ),
                          OptionBox(
                            
                            optionSelected: provider.optionSelected,
                            optionParameter: optiontree,
                            optionIndex: 'C.',
                            indexForQuestionNumber:
                                provider.currentQuestionIndex,
                            providerIndexForOption: 3,
                          ),
                          OptionBox(
                            optionSelected: provider.optionSelected,
                            optionParameter: optionfour,
                            optionIndex: 'D.',
                            indexForQuestionNumber:
                                provider.currentQuestionIndex,
                            providerIndexForOption: 4,
                          ),
                          Consumer<IndexController>(
                              builder: (context, provider, child) {
                            indexForQuestionNumber =
                                provider.currentQuestionIndex;
                            selectedOption = provider.optionSelected;

                            return selectedOption > 0
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              height: 45,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      offset: Offset(1, 5),
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.25),
                                                      blurRadius: 1.5,
                                                      spreadRadius: 1,
                                                    ),
                                                    BoxShadow(
                                                        offset: Offset(1, 2),
                                                        color: Colors.white,
                                                        blurRadius: 1,
                                                        spreadRadius: 1)
                                                  ]),
                                              child: ListTile(
                                                onTap: () {
                                                  marksForCorrectAnswers();
                                                  if (indexForQuestionNumber <
                                                      10) {
                                                    provider
                                                        .updateIndexForQuestion();
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ResultPage(
                                                            marksEarnedFromQuiz:
                                                                marksObtainedFromCorrectAnswer,
                                                          ),
                                                        ));
                                                  }
                                                  provider
                                                      .selectedOptionIndex(0);
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                tileColor: Colors.white,
                                                leading: Text(
                                                  'SONRAKİ',
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color.fromRGBO(
                                                        66, 130, 241, 1),
                                                  ),
                                                ),
                                                title: const Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 20,
                                                    bottom: 5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox(
                                    height: 65,
                                  );
                          })
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          } else {
            return Text("Bağlantı kurulamadı");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          throw "Hata";
        }
      },
    );
  }

  void marksForCorrectAnswers() {
    if (selectedOption == answers[indexForQuestionNumber]) {
      marksObtainedFromCorrectAnswer++;
    }
  }
}
