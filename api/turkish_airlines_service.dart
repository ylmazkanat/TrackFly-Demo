// api/turkish_airlines_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TurkishAirlinesService {
  final String apiUrl = 'https://developer.turkishairlines.com/endpoint'; // Güncel URL’yi kullanın
  final String apiKey = 'xxxxxx'; // Turkish Airlines API anahtarınızı buraya ekleyin

  Future<Map<String, dynamic>?> fetchFlightStatus(String pnr) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?pnr=$pnr&access_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to load Turkish Airlines flight status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
