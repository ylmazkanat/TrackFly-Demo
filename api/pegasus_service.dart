// api/pegasus_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PegasusService {
  final String apiUrl = 'https://devportal.flypgs.com/endpoint'; // Güncel URL’yi kullanın
  final String apiKey = 'xxxxxx'; // Pegasus API anahtarınızı buraya ekleyin

  Future<Map<String, dynamic>?> fetchFlightStatus(String pnr) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?pnr=$pnr&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to load Pegasus flight status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
