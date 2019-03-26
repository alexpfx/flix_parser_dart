import 'package:flix_parser_dart/fetch/get_movies.dart';
import 'package:flix_parser_dart/fetch/parse_movies.dart';

Future fetchMovies() async {
//  List<Map<String, dynamic>> rawMovies = await ParseMovieSummary(5).execute();
  
//  var x = await ParseMovieDetail("/se-joga-charlie/33698").execute();


  var info = GetTMDBInfo('tt0110912').execute();




}
