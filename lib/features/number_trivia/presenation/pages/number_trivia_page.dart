import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presenation/bloc/number_trivia_bloc.dart';
import 'package:flutter_clean_architecture/injection_container.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NumberTrivia"),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      builder: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              //TOP HALF
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(
                      message: "Start searching",
                    );
                  } else if (state is Error) {
                    return MessageDisplay(message: state.message);
                  } else if (state is Loaded) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is Loading) {
                    return LoadingWidget();
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              //BOTTOM HALF
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Input a number",
          ),
          onChanged: (value) {
            inputStr = value;
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                onPressed: dispatchConcrete,
                child: Text("Search"),
                textTheme: ButtonTextTheme.primary,
                color: Theme.of(context).accentColor,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: RaisedButton(
                onPressed: dispatchRandom,
                child: Text("Get random trivia"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .dispatch(GetTriviaForConcreteNumber(inputStr));
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .dispatch(GetTriviaForRandomNumber());
  }
}
