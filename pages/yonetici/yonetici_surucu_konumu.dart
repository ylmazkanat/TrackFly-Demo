import 'package:flutter/material.dart';
import 'package:trackfly/db/db_helper.dart'; // Veritabanı bağlantısını sağlamak için
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart'; // flutter_map paketini dahil ettik
import 'package:latlong2/latlong.dart'; // LatLng kullanabilmek için
import 'header.dart'; // Header'ı dahil et
import 'footer.dart'; // Footer'ı dahil et
import 'package:url_launcher/url_launcher.dart'; // URL Launcher'ı dahil et
import 'package:trackfly/styles.dart'; // Import the styles file

class DriverLocationsPage extends StatefulWidget {
  const DriverLocationsPage({super.key});

  @override
  _DriverLocationsPageState createState() => _DriverLocationsPageState();
}

class _DriverLocationsPageState extends State<DriverLocationsPage> {
  List<Map<String, dynamic>> _driverLocations = []; // Sürücülerin konumları
  List<Map<String, dynamic>> _filteredDriverLocations = []; // Filtrelenmiş sürücü konumları
  bool isLoading = true; // Veri yükleniyor durumu
  final int _selectedIndex = 0; // Footer'da seçili olan index
  MapController mapController = MapController(); // MapController'ı doğrudan başlatıyoruz
  final TextEditingController _searchController = TextEditingController(); // Arama çubuğu için controller

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission(); // İzin kontrolü
    _searchController.addListener(_filterDrivers); // Arama çubuğu dinleyicisi
  }

  @override
  void dispose() {
    _searchController.dispose(); // Controller'ı temizle
    super.dispose();
  }

  // Konum iznini kontrol et ve talep et
  Future<void> _checkAndRequestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Konum izni verildi, sürücü konumlarını yüklemeye başla
      _fetchDriverLocations();
    } else {
      // Konum izni verilmedi, kullanıcıya izin vermesi gerektiğini bildir
      print('Konum izni verilmedi');
      setState(() {
        isLoading = false; // İzin verilmediği için yükleme durumu false yapılır
      });
    }
  }

  // Veritabanından sürücü konumlarını çeker
  Future<void> _fetchDriverLocations() async {
    try {
      final conn = await DatabaseHelper.connect(); // Veritabanı bağlantısı
      final results = await conn.query(
        '''
        SELECT driver_username, enlem, boylam 
        FROM driver_locations
        ''', // Güncellenmiş veritabanı sorgusu
      );

      // Sürücü konumlarını liste halinde al
      List<Map<String, dynamic>> driverLocations = [];
      for (var row in results) {
        driverLocations.add({
          'driver_username': row['driver_username'],
          'enlem': row['enlem'],
          'boylam': row['boylam'],
        });
      }

      setState(() {
        _driverLocations = driverLocations;
        _filteredDriverLocations = driverLocations; // Başlangıçta tüm sürücüler gösterilir
        isLoading = false;
      });

      await conn.close();
    } catch (e) {
      print('Error fetching driver locations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sürücüleri arama çubuğuna göre filtrele
  void _filterDrivers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDriverLocations = _driverLocations.where((driver) {
        return driver['driver_username'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  // Google Maps'te bir konumu aç
  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Google Maps açılmadı';
    }
  }

  Future<String?> _getDriverProfileImage(String username) async {
    try {
      final conn = await DatabaseHelper.connect();
      final results = await conn.query(
        "SELECT profile_image FROM users WHERE username = ?",
        [username],
      );
      if (results.isNotEmpty) {
        return results.first['profile_image'];
      }
    } catch (e) {
      print('Veritabanı hatası: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Sürücü Konumları',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Sürücüleri Ara",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredDriverLocations.isEmpty
                      ? const Center(child: Text('Sürücü bulunamadı'))
                      : ListView.builder(
                          itemCount: _filteredDriverLocations.length,
                          itemBuilder: (context, index) {
                            final driver = _filteredDriverLocations[index];
                            return FutureBuilder<String?>(
                              future: _getDriverProfileImage(driver['driver_username']),
                              builder: (context, snapshot) {
                                final profileImageUrl = snapshot.data;
                                return GestureDetector(
                                  onTap: () {
                                    _openGoogleMaps(driver['enlem'], driver['boylam']);
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5,
                                    color: AppStyles.textColorWhite70, // Set background color to white
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: profileImageUrl != null
                                                ? NetworkImage(profileImageUrl)
                                                : const AssetImage('lib/images/profil.png') as ImageProvider,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sürücü: ${driver['driver_username']}', // Sürücü kullanıcı adı
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppStyles.textColor, // Use AppStyles for text color
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Enlem: ${driver['enlem']}, Boylam: ${driver['boylam']}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppStyles.textColor, // Use AppStyles for text color
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: FlutterMap(
                                                options: MapOptions(
                                                  center: LatLng(driver['enlem'], driver['boylam']),
                                                  zoom: 14,
                                                  interactiveFlags: InteractiveFlag.none, // Harita etkileşimlerini devre dışı bırak
                                                ),
                                                children: [
                                                  TileLayer(
                                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                    subdomains: const ['a', 'b', 'c'],
                                                  ),
                                                  MarkerLayer(
                                                    markers: [
                                                      Marker(
                                                        point: LatLng(driver['enlem'], driver['boylam']),
                                                        builder: (ctx) => const Icon(
                                                          Icons.location_on,
                                                          size: 20.0,
                                                          color: AppStyles.iconColorOrange,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
