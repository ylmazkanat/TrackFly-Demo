import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:trackfly/styles.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class KullaniciYolculukDetay extends StatelessWidget {
  final Map<String, dynamic> journey;

  const KullaniciYolculukDetay({super.key, required this.journey});

  String _formatTime(dynamic time) {
    try {
      if (time is String) {
        final parts = time.split(':');
        return '${parts[0]}:${parts[1]}';
      } else if (time is Duration) {
        final hours = time.inHours;
        final minutes = time.inMinutes.remainder(60);
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } else {
        return time.toString();
      }
    } catch (_) {
      return 'Belirtilmemiş';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<String?> _getFullName(String username) async {
    try {
      final conn = await DatabaseHelper.connect();
      final results = await conn.query(
        "SELECT full_name FROM users WHERE username = ?",
        [username],
      );
      if (results.isNotEmpty) {
        return results.first['full_name'];
      }
    } catch (e) {
      print('Veritabanı hatası: $e');
    }
    return null;
  }

  String _calculateRemainingTime(DateTime actualEndTime, String status) {
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final difference = actualEndTime.difference(currentTime);

    if (status == "İndi") {
      return 'İndi';
    } else if (difference.isNegative) {
      return '0 saat 0 dakika kaldı';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return '$hours saat $minutes dakika kaldı';
    }
  }

  Future<latlong.LatLng?> _getDriverLocation(String driverUsername) async {
    try {
      final conn = await DatabaseHelper.connect();
      final results = await conn.query(
        'SELECT enlem, boylam FROM driver_locations WHERE driver_username = ?',
        [driverUsername],
      );
      if (results.isNotEmpty) {
        final row = results.first;
        return latlong.LatLng(row['enlem'], row['boylam']);
      }
    } catch (e) {
      print('Veritabanı hatası: $e');
    }
    return null;
  }

  Future<void> _openGoogleMaps(latlong.LatLng location) async {
    final url = 'https://www.google.com/maps?q=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Google Maps açılamadı';
    }
  }

  Future<void> _openGoogleMapsWithCoordinates(String coordinates) async {
    final url = 'https://www.google.com/maps?q=$coordinates';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Google Maps açılamadı';
    }
  }

  Future<void> _openWhatsApp(BuildContext context ,String message) async {
    try {
      final conn = await DatabaseHelper.connect();
      final results = await conn.query(
        "SELECT phone FROM users WHERE username = ?",
        [journey['driver_username']],
      );
      if (results.isNotEmpty) {
        final phone = results.first['phone'];
        final formattedPhone = phone.replaceAll(RegExp(r'\D'), '');
        final url = Uri.parse('https://wa.me/$formattedPhone?text=$message');
        final canLaunchUrl = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!canLaunchUrl) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("WhatsApp uygulaması açılamadı!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sürücünün telefon numarası bulunamadı!")),
        );
      }
    } catch (e) {
      print('Veritabanı hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu!")),
      );
    }
  }

  Future<Map<String, dynamic>> _calculateDriverRemainingTime(latlong.LatLng driverLocation) async {
    final adnanMenderesLat = 38.2924;
    final adnanMenderesLng = 27.1567;

    final distance = Geolocator.distanceBetween(
      driverLocation.latitude,
      driverLocation.longitude,
      adnanMenderesLat,
      adnanMenderesLng,
    );

    final time = (distance / 1000) / 60; // Assuming average speed of 60 km/h
    return {
      'distance': (distance / 1000).toInt(), // Convert to kilometers
      'time': (time * 60).toInt(), // Convert to minutes
    };
  }

  String _translateCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'Güneşli';
      case 'partly cloudy':
        return 'Parçalı Bulutlu';
      case 'cloudy':
        return 'Bulutlu';
      case 'rain':
      case 'rainy':
        return 'Yağmurlu';
      case 'snow':
      case 'snowy':
        return 'Karlı';
      case 'thunderstorm':
        return 'Fırtınalı';
      default:
        return condition;
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.cloud_queue;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
      case 'rainy':
        return Icons.grain;
      case 'snow':
      case 'snowy':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  Future<String> _predictDelayWithGemini(String condition, int chanceOfRain, String flightInfo) async {
    final apiKey = 'AIzaSyC0iu3CWbfCqCO9mN1oK76Ylq62fyEivE0';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Predict delay based on the following information in Turkish and limit the response to 20 words: Weather condition: $condition, Chance of rain: $chanceOfRain%, Flight information: $flightInfo"}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['candidates'] != null && data['candidates'].isNotEmpty && data['candidates'][0]['content'] != null && data['candidates'][0]['content']['parts'] != null && data['candidates'][0]['content']['parts'].isNotEmpty) {
          final prediction = data['candidates'][0]['content']['parts'][0]['text'];
          return prediction; 
        } else {
          print('API response format unexpected: $data');
          return 'Rötar tahmini yapılamadı.';
        }
      } else {
        print('API hatası: ${response.body}');
        return 'Rötar tahmini yapılamadı.';
      }
    } catch (e) {
      print('API hatası: $e');
      return 'Rötar tahmini yapılamadı.';
    }
  }

  Future<String> _getWeatherForecast(DateTime dateTime) async {
    // Replace with your actual weather API endpoint and key
    final apiKey = '87af53e660764d37823141840251001'; // Update this line with your new API key
    final adnanMenderesLat = 38.2924;
    final adnanMenderesLng = 27.1567;
    final url = 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$adnanMenderesLat,$adnanMenderesLng&dt=${dateTime.toIso8601String().split('T')[0]}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecast = data['forecast']['forecastday'][0]['day'];
        final condition = forecast['condition']['text'];
        final translatedCondition = _translateCondition(condition);
        final chanceOfRain = forecast['daily_chance_of_rain'];
        final flightInfo = 'Flight from ${journey['route_start_location']} to ${journey['route_end_location']}';
        final delayPrediction = await _predictDelayWithGemini(condition, chanceOfRain, flightInfo);
        return jsonEncode({
          'condition': translatedCondition,
          'chanceOfRain': chanceOfRain,
          'delayPrediction': delayPrediction
        });
      } else {
        print('Hava durumu API hatası: ${response.body}');
        return 'Hava durumu bilgisi alınamadı.';
      }
    } catch (e) {
      print('Hava durumu hatası: $e');
      return 'Hava durumu bilgisi alınamadı.';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime estimatedArrival;
    DateTime actualStartTime;
    try {
      estimatedArrival = DateTime.parse(journey['estimated_duration']).toLocal();
    } catch (_) {
      print("Tarih hatalı: ${journey['estimated_duration']}");
      
      estimatedArrival = journey['actual_end_time']; // Hatalı durumda orijinal değer atanıyor
    }

    try {
      actualStartTime = DateTime.parse(journey['actual_start_time']).toLocal();
    } catch (_) {
      print("Tarih hatalı: ${journey['actual_start_time']}");
      actualStartTime = journey['actual_start_time']; // Hatalı durumda orijinal değer atanıyor

      
    }

    return Scaffold(
      appBar:  Header(
        title: "Yolculuk Detayı",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: FutureBuilder<latlong.LatLng?>(
        future: _getDriverLocation(journey['driver_username'] ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final driverLocation = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yolculuk Detayları",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.location_on, "Başlangıç:", journey['route_start_location'] ?? "Belirtilmemiş"),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.flag, "Varış:", journey['route_end_location'] ?? "Belirtilmemiş"),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openGoogleMapsWithCoordinates(journey['route_end_taksi'] ?? ""),
                  child: _buildDetailRowWithCopy(
                    context,
                    Icons.location_on, 
                    "Gidilecek Nokta:", 
                    journey['route_end_taksi_yazili'] ?? "Belirtilmemiş"
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                _buildDetailRow(Icons.confirmation_number, "PNR Kodu:", journey['pnr'] ?? "Yok"),
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: _getFullName(journey['yolcu_username']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final fullName = snapshot.data ?? "Belirtilmemiş";
                    return _buildDetailRow(Icons.person, "Yolcu:", fullName);
                  },
                ),
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: _getFullName(journey['driver_username']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final fullName = snapshot.data ?? "Atanmadı";
                    return _buildDetailRow(Icons.person_outline, "Sürücü:", fullName);
                  },
                ),
                const Divider(height: 30, thickness: 1),
                _buildDetailRow(Icons.access_time, "Tahmini İniş Saati:", _formatTime(journey['estimated_duration'])),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.timer, "Başlangıç Saati:", _formatDateTime(actualStartTime)),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.timer_off, "Bitiş Saati:", _formatDateTime(estimatedArrival)),
                const Divider(height: 30, thickness: 1),
                _buildDetailRow(Icons.info, "Durum:", journey['status'] ?? "Belirtilmemiş", statusColor: AppStyles.iconColorOrange),
                const SizedBox(height: 20),
                _buildRemainingTimeRow(estimatedArrival, journey['status']),
                const SizedBox(height: 20),
                if (driverLocation != null) ...[
                  FutureBuilder<Map<String, dynamic>>(
                    future: _calculateDriverRemainingTime(driverLocation),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final driverInfo = snapshot.data ?? {'distance': 0, 'time': 0};
                      return _buildDriverRemainingTimeRow(driverInfo['distance'], driverInfo['time']);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                FutureBuilder<String>(
                  future: _getWeatherForecast(estimatedArrival),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      final weatherData = jsonDecode(snapshot.data!);
                      final condition = weatherData['condition'];
                      final chanceOfRain = weatherData['chanceOfRain'];
                      final delayPrediction = weatherData['delayPrediction'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getWeatherIcon(condition), color: AppStyles.buttonColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hava Durumu: $condition, Yağmur Olasılığı: %$chanceOfRain',
                                  style: const TextStyle(fontSize: 16, color: AppStyles.textColor),
                                  overflow: TextOverflow.visible, // Allow text to wrap to the next line
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.psychology, color: AppStyles.buttonColor), // Use 'psychology' icon instead
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rötar Tahmini: $delayPrediction',
                                  style: const TextStyle(fontSize: 16, color: AppStyles.textColor),
                                  overflow: TextOverflow.visible, // Allow text to wrap to the next line
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return const Text('Hava durumu bilgisi alınamadı.');
                    }
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(context,"Selam Uçaktan indim Geliyorum."),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle, color: AppStyles.textColorWhite),
                          label: const Text("Geliyorum"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(context,"Merhaba bir sorunum var. sorunum:"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.report_problem, color: AppStyles.textColorWhite),
                          label: const Text("Sorun Bildirim Gönder"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Sürücü Konumu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (driverLocation != null) ...[
                  SizedBox(
                    height: 300,
                    child: FlutterMap(
                      options: MapOptions(
                        center: driverLocation,
                        zoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: driverLocation,
                              builder: (context) => const Icon(Icons.location_on, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(driverLocation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.map, color: AppStyles.textColorWhite),
                      label: const Text("Konuma Git", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  const Text("Sürücü konumu bulunamadı."),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const Footer(selectedIndex: 1),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppStyles.buttonColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: statusColor ?? AppStyles.textColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithCopy(BuildContext context, IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppStyles.buttonColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, size: 14, color: AppStyles.buttonColor),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Adres kopyalandı!")),
                  );
                },
              ),
              const SizedBox(width: 4), // Add some space between icon and text
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: AppStyles.buttonColor),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.visible, // Allow text to wrap to the next line
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingTimeRow(DateTime estimatedArrival, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.timer, color: AppStyles.buttonColor),
            SizedBox(width: 8),
            Text(
              "İnişe Kalan Süre:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          _calculateRemainingTime(estimatedArrival, status),
          style: TextStyle(
            fontSize: 16,
            color: estimatedArrival.isBefore(DateTime.now()) ? AppStyles.buttonColor : AppStyles.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverRemainingTimeRow(int distance, int time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.timer, color: AppStyles.buttonColor),
            SizedBox(width: 8),
            Text(
              "Sürücü Kalan Süre:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          '$distance km - $time dakika',
          style: const TextStyle(fontSize: 16, color: AppStyles.textColor),
        ),
      ],
    );
  }
}
