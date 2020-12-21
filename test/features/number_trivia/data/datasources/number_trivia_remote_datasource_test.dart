import 'dart:convert';
import 'package:flutter_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:flutter_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200(){
    when(mockHttpClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(fixture("trivia.json"), 200));
  }

  setUpMockHttpClientFailure404(){
    when(mockHttpClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("Something went wrong", 404));
  }

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture("trivia.json")));
    test(
        "should perform a GET on a URL with number being the endpoint and with application/json header",
        () async {
      //arrange
        setUpMockHttpClientSuccess200();
      //act
      dataSource.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockHttpClient.get("http://numbersapi.com/$tNumber",
          headers: {"Content-Type": "application/json"}));
    });

    test("should return NumberTrivia when the response code is 200",() async{
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test("should throw a ServerException when the response code is other than 200", () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = dataSource.getConcreteNumberTrivia;
      //assert
      expect(()=> call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group("getRandomNumberTrivia", (){
    final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture("trivia.json")));
    test(
        "should perform a GET on a URL with number being the endpoint and with application/json header",
            () async {
          //arrange
          setUpMockHttpClientSuccess200();
          //act
          dataSource.getRandomNumberTrivia();
          //assert
          verify(mockHttpClient.get("http://numbersapi.com/random",
              headers: {"Content-Type": "application/json"}));
        });

    test("should return NumberTrivia when the response code is 200",() async{
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSource.getRandomNumberTrivia();
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test("should throw a ServerException when the response code is other than 200", () async {
      //arrange
      setUpMockHttpClientFailure404();
      //act
      final call = dataSource.getRandomNumberTrivia;
      //assert
      expect(()=> call(), throwsA(isA<ServerException>()));
    });

  });
}
