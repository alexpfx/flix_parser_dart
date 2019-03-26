import 'package:dio/dio.dart';

/// Obtém título original, released, runtime, plot, language, country, poster, ratings: imdb, rt, metacritic.
class GetTMDBInfo {
  String idImdb;

  GetTMDBInfo(this.idImdb);

  String baseUrl = 'http://www.omdbapi.com/';

  String apiKey = 'a47dbb88';

  Future<Map<String, dynamic>> execute() async {
    return await get(apiKey, idImdb);
  }

  Future get(String apiKey, String imdbId) async {
    Response response = await Dio()
        .get(baseUrl, queryParameters: {'apiKey': apiKey, 'i': idImdb});

    if (response.statusCode != 200) {
      throw Exception('error getting');
    }
    return response.data;
  }
}
