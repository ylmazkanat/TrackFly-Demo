import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, double>>> fetchDriverLocations() async {
  final response = await http.get(Uri.parse('https://your-api-url.com/get-driver-locations'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<Map<String, double>> locations = [];
    for (var location in data) {
      locations.add({
        'latitude': location['latitude'],
        'longitude': location['longitude'],
      });
    }
    return locations;
  } else {
    throw Exception('Failed to load driver locations');
  }
}
