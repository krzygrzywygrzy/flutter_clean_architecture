import 'dart:math';

import 'package:flutter_clean_architecture/core/util/input_converter.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/usecases/get_radnom_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presenation/bloc/number_trivia_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia concreteNumberTrivia;
  MockGetRandomNumberTrivia randomNumberTrivia;
  MockInputConverter inputConverter;

  setUp(() {
    concreteNumberTrivia = MockGetConcreteNumberTrivia();
    randomNumberTrivia = MockGetRandomNumberTrivia();
    inputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        concrete: concreteNumberTrivia,
        random: randomNumberTrivia,
        inputConverter: inputConverter);
  });

  test("initialState should be Empty", () {
    //assert
    expect(bloc.initialState, equals(Empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    final tNumberString = "1";
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    test(
        "should call the InputConverter to validate and convert the string ti an unsigned integer",
        () async {
      //arrange
      when(inputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(inputConverter.stringToUnsignedInteger(any));
      //assert
      verify(inputConverter.stringToUnsignedInteger(tNumberString));
    });

    test("should emit [Error] when the input is invalid", () async {
      //arrange
      when(inputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      //assert
      final expected = [
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(
        bloc.state,
        emitsInOrder(expected),
      );

      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });
}
