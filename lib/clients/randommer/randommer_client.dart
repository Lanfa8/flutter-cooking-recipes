import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

enum LoremType { normal, business }

enum Type { paragraphs, words }

class RandommerClient {
  final String baseUrl;
  final Client client;
  final String apiKey;

  RandommerClient({Client? client})
    : baseUrl = 'https://randommer.io',
      client = client ?? Client(),
      apiKey = dotenv.env['RANDOMMER_API_KEY'] ?? '' {
    if (apiKey.isEmpty) {
      throw ArgumentError(
        'API key is missing. Please set the RANDOMMER_API_KEY in the .env file.',
      );
    }
  }

  Future<String> getRandomText(
    LoremType loremType,
    Type type,
    int number,
  ) async {
    var uri = Uri.parse('$baseUrl/api/Text/LoremIpsum');
    uri.queryParameters.addAll({
      'lorem_type': loremType.name,
      'type': type.name,
      'number': number.toString(),
    });

    final response = await client.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode != 200) {
      throw Exception('Failed to load random text');
    }

    return response.body;
  }

  Future<List<dynamic>> getSuggestions(String startingWords) async {
    var uri = Uri.parse(
      baseUrl,
    ).replace(path: '/api/Name/Suggestions', queryParameters: {'startingWords': startingWords});

    final response = await client.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode != 200) {
      throw Exception('Failed to load suggestions');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }
}
