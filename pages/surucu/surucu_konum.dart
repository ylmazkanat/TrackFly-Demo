import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../genel/user_provider.dart';
import 'package:geolocator/geolocator.dart';
import '/db/db_helper.dart';
import 'footer.dart';
import 'header.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class SurucuKonum extends StatefulWidget {
  const SurucuKonum({super.key});

  @override
  _SurucuKonumState createState() => _SurucuKonumState();
}

class _SurucuKonumState extends State<SurucuKonum> {
  bool isLoading = true;
  final int _selectedIndex = 0;
  MapController mapController = MapController();
  Position? currentPosition;
  Timer? positionUpdateTimer;
  String? userId;
  bool showNotification = false;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _checkAndRequestLocationPermission();
    _startPositionUpdateTimer();
  }

  @override
  void dispose() {
    positionUpdateTimer?.cancel();
    super.dispose();
  }

  void _getUserId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      userId = userProvider.username;
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _updatePosition();
      setState(() {
        isLoading = false;
      });
    } else {
      print('Konum izni verilmedi');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startPositionUpdateTimer() {
    positionUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updatePosition();
    });
  }

  Future<void> _updatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
      });

      mapController.move(LatLng(position.latitude, position.longitude), 14);

      if (userId != null) {
        await _updateDatabase(userId!, position.latitude, position.longitude);
        _showNotification();
      }
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  Future<void> _updateDatabase(String driverUsername, double latitude, double longitude) async {
    try {
      final conn = await DatabaseHelper.connect();

      var result = await conn.query(
        'SELECT * FROM driver_locations WHERE driver_username = ?',
        [driverUsername],
      );

      if (result.isNotEmpty) {
        await conn.query(
          '''
          UPDATE driver_locations 
          SET enlem = ?, boylam = ?, timestamp = NOW() 
          WHERE driver_username = ? 
          ''',
          [latitude, longitude, driverUsername],
        );
        print("Konum başarıyla güncellendi.");
      } else {
        await conn.query(
          '''
          INSERT INTO driver_locations (driver_username, enlem, boylam, timestamp) 
          VALUES (?, ?, ?, NOW())
          ''',
          [driverUsername, latitude, longitude],
        );
        print("Yeni konum kaydı oluşturuldu.");
      }

      await conn.close();
    } catch (e) {
      print("Veritabanı hatası: $e");
    }
  }

  void _showNotification() {
    setState(() {
      showNotification = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Konumum',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: currentPosition != null
                        ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                        : LatLng(0, 0),
                    zoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              size: 40.0,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  bottom: 60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppStyles.textColorWhite, // Use AppStyles for color
                      boxShadow: const [
                        BoxShadow(
                          color: AppStyles.textColor, // Use AppStyles for color
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Konum Bilgisi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (currentPosition != null) ...[
                          Text('Enlem: ${currentPosition!.latitude.toStringAsFixed(6)}'),
                          Text('Boylam: ${currentPosition!.longitude.toStringAsFixed(6)}'),
                        ] else
                          const Text('Konum yükleniyor...'),
                        ElevatedButton(
                          onPressed: _updatePosition,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.buttonColor, // Set the button color
                          ),
                          child: const Text('Konumu Güncelle'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showNotification)
                  Positioned(
                    bottom: 10,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'Konum güncellendi!',
                        style: TextStyle(color: AppStyles.textColorWhite), // Use AppStyles for color
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: Footer(selectedIndex: _selectedIndex),
    );
  }
}
