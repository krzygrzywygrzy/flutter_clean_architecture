import 'dart:convert';
import 'package:flutter_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group("getLastNumberTrivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture("trivia_cached.json")));
    test(
        "should return NumberTrivia form SharedPreferences when there is one in the cache",
        () async {
      //arrange
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture("trivia_cached.json"));
      //act
      final result = await dataSource.getLastNumberTrivia();
      //arrange
      verify(mockSharedPreferences.getString("CACHED_NUMBER_TRIVIA"));
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        "should throw CacheException when there is not a chached value",
            () async {
          //arrange
          when(mockSharedPreferences.getString(any))
              .thenReturn(null);
          //act
          final call =  dataSource.getLastNumberTrivia;
          //arrange
          expect(()=> call(), throwsA(isA<CacheException>()));
        });

  });

  group("cacheNumberTrivia", (){
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: "Test Trivia");
    test("should call SharedPreferences to cache the data", () async {
      //arrange
      //act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      //assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString("CACHED_NUMBER_TRIVIA", expectedJsonString));
    });
  });

}
