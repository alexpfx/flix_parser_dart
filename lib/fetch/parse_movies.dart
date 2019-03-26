import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

var baseUrl = 'https://www.nonetflix.com.br';

/// Obtém o link, o tipo, filme ou série e a data em que foi adicionado ao catálogo.
class ParseMovieSummary {
  int pages = 0;

  ParseMovieSummary(this.pages);

  Future<List<Map<String, dynamic>>> execute() async {
    var movies = [];

    await initializeDateFormatting("pt_BR", null);

    for (int i = 1; i <= pages; i++) {
      Document doc = await get(baseUrl + "/novos-filmes/?p=$i");

      doc.querySelectorAll("[id^=MainContent_rpList_divRow_]").forEach((e) {
        String divFooter =
            e.querySelector('[id^=MainContent_rpList_divFooter_]').text;

        List splitedFooter = List.of(divFooter.split("|").map((s) => s.trim()));

        var type = splitedFooter[1];
        var relativeUrl = e.querySelector(".mtitle > a").attributes['href'];

        DateTime date = parseDate(splitedFooter[0]);

        movies.add({'link': relativeUrl, 'date': date, 'type': type});
      });
    }

    return movies;
  }

  Future<Document> getDocument(int i) async {
    var pageUrl = baseUrl + "/novos-filmes/?p=$i";
    return await get(pageUrl);
  }

  DateTime parseDate(String strDate) {
    var fullDate = strDate.replaceAll(" ", " de ");
    DateFormat("dd MMMM yyyy");
    var date = DateFormat.yMMMMd("pt_BR").parse(fullDate);
    return date;
  }
}




/// Obtém a descrição, nome do filme, o ano, e o imdb id e os generos, netflixid.
class ParseMovieDetail {
  String relativeUrl;

  ParseMovieDetail(this.relativeUrl);

  Future<Map<String, dynamic>> execute() async {
    Document doc = await get(baseUrl + relativeUrl);

    String title = getTitle(doc);
    String description = getPlot(doc);
    String imdbUrl = getImdbUrl(doc);
    String netflixUrl = getNetflixId(doc);
    String year = getYear(doc);
    List<String> genres = getGenres(doc);
    String imdbId = getImdbId(imdbUrl);

    return {
      'title': title,
      'description': description,
      'imdbUrl': imdbUrl,
      'netflixUrl': netflixUrl,
      'year': year,
      'genres': genres,
      'imdbId': imdbId
    };
  }

  String getTitle(Document doc) => doc
      .getElementsByTagName('meta[property="og:title"]')
      .first
      .attributes['content'];

  String getPlot(Document doc) => doc
      .getElementsByTagName('meta[property="og:description"]')
      .first
      .attributes['content'];

  String getImdbUrl(Document doc) =>
      doc.querySelector(".bml > #MainContent_hypIMDBUrl")?.attributes['href'] ??
      "";

  String getNetflixId(Document doc) =>
      doc.querySelector(".bmxl > #MainContent_hypPlay").attributes['href'];

  String getYear(Document doc) =>
      doc.querySelector('span[itemprop=dateCreated]').text;

  List<String> getGenres(Document doc) {
    var list = <String>[];
    doc.querySelectorAll('span[itemprop=genre]').forEach((genre) {
      list.add(genre.text);
    });

    return list;
  }

  String getImdbId(String imdbUrl) {
    if (imdbUrl != null) {
      return Uri.parse(imdbUrl).pathSegments[1];
    }



    return '';
  }
}

Future<Document> get(String pageUrl) async {

  http.Response response =
      await http.get(pageUrl, headers: {'User-Agent': 'Mozilla/4.0'});

  if (response.statusCode != 200) {
    throw new Exception("erro ao obter documento");
  }

  return parser.parse(response.body);
}
