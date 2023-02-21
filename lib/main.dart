import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:beacons_plugin_example/eserler.dart';
import 'package:beacons_plugin_example/jsonParser.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:beacons_plugin_example/models/muzemodel.dart';
import 'package:beacons_plugin_example/quiz/controller/index_controller.dart';
import 'package:beacons_plugin_example/quiz/view/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider<IndexController>(
    create: (context) => IndexController(),
    child: MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  String muzedesc = "";
  String muzetelno = "";
  String muzeadres = "";
  List<dynamic> muzeimages = <dynamic>[];
  List<Map<dynamic, dynamic>> questions = [];
  int selectedIndex = 0;
  String _tag = "Amasra Müzesi";
  String _beaconResult = 'Henüz Taranmadı';
  int _nrMessagesReceived = 0;
  double distance = double.infinity;
  var isRunning = false;
  List<String> _results = [];
  bool _isInForeground = true;
  var selectedColor = Colors.transparent;

  final ScrollController _scrollController = ScrollController();

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  addFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("scoreId") && prefs.containsKey("score")) {
      String? scoreId = prefs.getString("scoreId");
      int? storedScore = prefs.getInt("score");

      print(scoreId);

      await FirebaseFirestore.instance
          .collection('scores')
          .doc(scoreId)
          .update({"score": 50 + storedScore!});
      await prefs.setInt("score", 50 + storedScore);
    } else {
      await FirebaseFirestore.instance
          .collection('scores')
          .add({"score": 50}).then((value) async {
        if (!(prefs.containsKey(value.id))) {
          await prefs.setString("scoreId", value.id);
          await prefs.setInt("score", 50);
        }
      });
    }
  }

  Future<List<Muze>> getMuze() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('amasra').get();

    snapshot.docs.forEach((element) {
      muzedesc = element.data()["description"];
      muzeadres = element.data()["adress"];
      muzetelno = element.data()["telno"];
      muzeimages = element.data()["images"];
    });

    return snapshot.docs
        .map((docSnapshot) => Muze.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  getRandomQuestion() async {
    await FirebaseFirestore.instance.collection("sorular").get().then((value) {
      value.docs.forEach((element) {
        if (!(questions.contains(element.data()))) {
          questions.add(element.data());
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMuze();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Konum Servisi",
          message: " Uygulama Konumunuza erismek istiyor");
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");

    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty && isRunning) {
            setState(() {
              _beaconResult = data;
              _results.add(_beaconResult);
              _nrMessagesReceived++;
            });

            var encoded = json.decode(data);
            Map<String, dynamic> valueMap = encoded;
            JsonFormat values = JsonFormat.fromJson(valueMap);
            setState(() {
              distance = values.distance;
            });
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    await BeaconsPlugin.runInBackground(true);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (distance < 1.0) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          isRunning = false;
          distance = double.infinity;
        });
        connectivity(context);
      });
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.account_balance_outlined),
            onPressed: () {
              museumInfo(context);
            },
          ),
          title: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ));
              },
              child: Center(
                child: const Text('Amasra Müzesi'),
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (isRunning) {
                    await BeaconsPlugin.stopMonitoring();
                  } else {
                    initPlatformState();
                    await BeaconsPlugin.startMonitoring();
                  }
                  setState(() {
                    isRunning = !isRunning;
                  });
                },
                child: isRunning
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text("Tara"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                child: Text("Quiz"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ));
                },
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Eserler(),
              )
            ],
          ),
        ),
      ),
    );
  }

  // void _showNotification(String subtitle) {
  //   var rng = new Random();
  //   Future.delayed(Duration(seconds: 5)).then((result) async {
  //     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //         'your channel id', 'your channel name',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         ticker: 'ticker');
  //     var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //     var platformChannelSpecifics = NotificationDetails(
  //         android: androidPlatformChannelSpecifics,
  //         iOS: iOSPlatformChannelSpecifics);
  //     await flutterLocalNotificationsPlugin.show(
  //         rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
  //         payload: 'item x');
  //   });
  // }

  void isDistance() {
    setState(() {
      isRunning = !isRunning;
    });
  }

/*
SORU-1: Hadrian beş iyi imparatorun kaçıncısıdır?
a) Birincisi
b) İkincisi
c) Üçüncüsü
d) Dördüncüsü
(cevap:C)
 */
  final question = Container(
    child: SingleChildScrollView(
      child: Expanded(
        child: ListView(
          children: [
            Text("Hadrian beş iyi imparatorun kaçıncısıdır?"),
            TextButton(
              child: Text(
                "A : Birincisi",
                selectionColor: Colors.red,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                print("A");
              },
            ),
            TextButton(
              child: Text("B : İkincisi"),
              onPressed: () {
                print("B");
              },
            ),
            TextButton(
              child: Text("C : Üçüncüsü"),
              onPressed: () {
                print("C");
              },
            ),
            TextButton(
              child: Text("D : Dördüncüsü"),
              onPressed: () {
                print("D");
              },
            ),
          ],
        ),
      ),
    ),
  );

  Future connectivity(BuildContext context) {
    var random = Random().nextInt(35);
    return showDialog<bool>(
        context: context,
        builder: (context) => SafeArea(
                child: FutureBuilder(
              future: getRandomQuestion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Dialog(
                    backgroundColor: Colors.black12,
                    insetPadding: EdgeInsets.all(10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.lightBlue),
                            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    questions[random]["kategori"],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18,
                                      letterSpacing: -0.3,
                                      color: const Color.fromRGBO(
                                          255, 248, 255, 1),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    questions[random]["soru"],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.3,
                                      color: const Color.fromRGBO(
                                          255, 248, 255, 1),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15, left: 15),
                                    child: ListTile(
                                      onTap: () async {
                                        if (questions[random]["cevap"] == 1) {
                                          Navigator.pop(context);
                                          _showDialog("Harika!!!",
                                              "Soruyu doğru cevaplayıp 50 puan kazandınız.");
                                          await addFirestore();
                                        } else {
                                          Navigator.pop(context);

                                          _showDialog("Cevap Yanlış",
                                              "Maalesef 50 puanı kazanamadınız.");
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      tileColor: Colors.amber[400],
                                      leading: Text(
                                        "A",
                                        style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(
                                              212, 212, 212, 1),
                                        ),
                                      ),
                                      title: Text(
                                        questions[random]["a"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.3,
                                          color: const Color.fromRGBO(
                                              255, 248, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15, left: 15),
                                    child: ListTile(
                                      onTap: () async {
                                        if (questions[random]["cevap"] == 2) {
                                          Navigator.pop(context);

                                          _showDialog("Harika!!!",
                                              "Soruyu doğru cevaplayıp 50 puan kazandınız.");
                                          await addFirestore();
                                        } else {
                                          Navigator.pop(context);

                                          _showDialog("Cevap Yanlış",
                                              "Maalesef 50 puanı kazanamadınız.");
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      tileColor: Colors.amber[400],
                                      leading: Text(
                                        "B",
                                        style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(
                                              212, 212, 212, 1),
                                        ),
                                      ),
                                      title: Text(
                                        questions[random]["b"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.3,
                                          color: const Color.fromRGBO(
                                              255, 248, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15, left: 15),
                                    child: ListTile(
                                      onTap: () async {
                                        if (questions[random]["cevap"] == 3) {
                                          Navigator.pop(context);
                                          _showDialog("Harika!!!",
                                              "Soruyu doğru cevaplayıp 50 puan kazandınız.");
                                          await addFirestore();
                                        } else {
                                          Navigator.pop(context);

                                          _showDialog("Cevap Yanlış",
                                              "Maalesef 50 puanı kazanamadınız.");
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      tileColor: Colors.amber[400],
                                      leading: Text(
                                        "C",
                                        style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(
                                              212, 212, 212, 1),
                                        ),
                                      ),
                                      title: Text(
                                        questions[random]["c"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.3,
                                          color: const Color.fromRGBO(
                                              255, 248, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15, left: 15),
                                    child: ListTile(
                                      onTap: () async {
                                        if (questions[random]["cevap"] == 4) {
                                          Navigator.pop(context);
                                          _showDialog("Harika!!!",
                                              "Soruyu doğru cevaplayıp 50 puan kazandınız.");
                                          await addFirestore();
                                        } else {
                                          Navigator.pop(context);

                                          _showDialog("Cevap Yanlış",
                                              "Maalesef 50 puanı kazanamadınız.");
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      tileColor: Colors.amber[400],
                                      leading: Text(
                                        "D",
                                        style: GoogleFonts.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color.fromRGBO(
                                              212, 212, 212, 1),
                                        ),
                                      ),
                                      title: Text(
                                        questions[random]["d"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.3,
                                          color: const Color.fromRGBO(
                                              255, 248, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Positioned(
                            top: -25,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image.asset(
                                "Assets/qmark.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.transit_enterexit_outlined,
                                color: Colors.white,
                                size: 35,
                              ),
                            ))
                      ],
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  throw "Veri alınamadı";
                }
              },
            )));
    ;
  }

  void _showDialog(String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              child: new Text("Kapat"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future museumInfo(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) => SafeArea(
                child: FutureBuilder(
              future: getMuze(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Dialog(
                      backgroundColor: Colors.black12,
                      insetPadding: EdgeInsets.all(10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.7,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.lightBlue),
                              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Adres : " + muzeadres,
                                      style: GoogleFonts.mulish(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Telefon : " + muzetelno,
                                      style: GoogleFonts.mulish(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Amasra Müzesi",
                                      style: GoogleFonts.mulish(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 25,
                                        letterSpacing: -0.3,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      muzedesc,
                                      style: GoogleFonts.mulish(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                        letterSpacing: -0.3,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        height: 300.0,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image.network(
                                            muzeimages[0],
                                            width: 150,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        height: 300.0,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image.network(
                                            muzeimages[1],
                                            width: 150,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        height: 300.0,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image.network(
                                            muzeimages[2],
                                            width: 150,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        height: 300.0,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: Image.network(
                                            muzeimages[3],
                                            width: 150,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              )),
                          Positioned(
                              top: -50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Image.network(
                                  muzeimages[1],
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.transit_enterexit_outlined,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ))
                        ],
                      ),
                    );
                  } else {
                    return Text("Başarısız");
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  throw "Veri alınamadı";
                }
              },
            )));
  }
}
