import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionBox extends StatelessWidget {
  String question;
  String category;
  QuestionBox({Key? key, required this.question, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 5),
      child: SizedBox(
        height: 150,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category,
                textAlign: TextAlign.left,
                style: GoogleFonts.mulish(
                    fontSize: 18,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            SizedBox(
              height: 10,
            ),
            Text(
              question,
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3),
            ),
          ],
        ),
      ),
    );
  }
}
