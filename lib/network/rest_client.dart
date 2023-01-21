import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:mymap/network/model/basic_response.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: "http://localhost/ninja-api/wsbpsapp")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('/rsList/{search_word}')
  Future<BasicResponse> getRadioStationList(@Path("search_word") String search_word);

  @GET('/getSuggestion/{search_word}')
  Future<BasicResponse> getSuggestion(@Path("search_word") String search_word);
}