// api/amadeus_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AmadeusService {
  final String apiKey = 'xxxxxx';
  final String apiSecret = 'xxxxxx';
  final String tokenUrl = 'https://test.api.amadeus.com/v1/security/oauth2/token';
  final String flightInfoUrl = 'https://test.api.amadeus.com/v1/reference-data/airlines';

  String? _accessToken;

  // Token alma fonksiyonu
  Future<void> fetchToken() async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      _accessToken = jsonData['access_token'];
    } else {
      throw Exception('Failed to obtain access token: ${response.statusCode}');
    }
  }

  // Uçuş bilgilerini sorgulama fonksiyonu
  Future<Map<String, dynamic>?> fetchFlightInfo(String airlineCode) async {
    if (_accessToken == null) {
      await fetchToken();
    }

    final response = await http.get(
      Uri.parse('$flightInfoUrl?airlineCodes=$airlineCode'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      await fetchToken();
      return fetchFlightInfo(airlineCode);
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      final error = json.decode(response.body);
      throw Exception('Error: ${error['errors'][0]['title']} - ${error['errors'][0]['detail']}');
    } else {
      throw Exception('Unexpected error: ${response.statusCode}');
    }
  }
}
