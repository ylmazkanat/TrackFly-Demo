// api/flight_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class FlightService {
  final String apiKey = 'xxxxxx';
  final String baseUrl = 'http://api.aviationstack.com/v1';

  Future<Map<String, dynamic>?> fetchFlightStatus(String flightCode) async {
    final url = Uri.parse('$baseUrl/flights?access_key=$apiKey&flight_iata=$flightCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
