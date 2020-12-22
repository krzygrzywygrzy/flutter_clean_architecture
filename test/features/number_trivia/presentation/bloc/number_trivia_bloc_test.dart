import 'dart:math';

import 'package:flutter_clean_architecture/core/error/failures.dart';
import 'package:flutter_clean_architecture/core/usecases/usecase.dart';
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

    void setUpMockInputConverterSuccess() =>
        when(inputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test(
        "should call the InputConverter to validate and convert the string ti an unsigned integer",
        () async {
      //arrange
      setUpMockInputConverterSuccess();
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

    test("should get data from ConcreteUsecase", () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(concreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(concreteNumberTrivia(any));
      //assert
      verify(concreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test("should emit [Loading, Loaded] when data is gotten succesfully",
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(concreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test("should emit [Loading, Error] when getting data fails", () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(concreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
    test(
        "should emit [Loading, Error] with proper message for the error when getting data fails",
        () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(concreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group("GetTriviaForRandomNumber", () {
    final tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    test("should get data from random usecase", () async {
      //arrange

      when(randomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.dispatch(GetTriviaForRandomNumber());
      await untilCalled(randomNumberTrivia(any));
      //assert
      verify(randomNumberTrivia(NoParams()));
    });

    test("should emit [Loading, Loaded] when data is gotten succesfully",
        () async {
      //arrange

      when(randomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test("should emit [Loading, Error] when getting data fails", () async {
      //arrange
      when(randomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });
    test(
        "should emit [Loading, Error] with proper message for the error when getting data fails",
        () async {
      //arrange
      when(randomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });
  });
}
