import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia numberTrivia;

  const TriviaDisplay({
    Key key,
    @required this.numberTrivia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Expanded(
        child: Center(
          child: Column(
            children: [
              Text(
                numberTrivia.number.toString(),
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
              SingleChildScrollView(
                child: Text(
                  numberTrivia.text,
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
