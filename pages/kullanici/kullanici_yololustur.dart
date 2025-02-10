import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:trackfly/db/db_helper.dart';
import 'kullanici_yolculuklar.dart';
import 'package:trackfly/styles.dart';

class KullaniciYolculukOlusturma extends StatefulWidget {
  const KullaniciYolculukOlusturma({super.key});

  @override
  _KullaniciYolculukOlusturmaState createState() =>
      _KullaniciYolculukOlusturmaState();
}

class _KullaniciYolculukOlusturmaState
    extends State<KullaniciYolculukOlusturma> {
  final int _selectedIndex = 0;
  final TextEditingController _varisNoktasiController = TextEditingController();
  final TextEditingController _pnrController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedInisNoktasi;
  String? _selectedValizBoyutu;
  LatLng _selectedLocation = LatLng(39.9334, 32.8597); // Default: Ankara
  String _selectedAddress = "Adres seçilmedi";
  bool _isLoading = false;
  String? _selectedDriver;
  List<Map<String, dynamic>> _drivers = [];

  final List<String> _inisNoktalari = [
    'İstanbul Havalimanı',
    'Sabiha Gökçen Havalimanı',
    'Ankara Esenboğa Havalimanı',
    'İzmir Adnan Menderes Havalimanı',
    'Antalya Havalimanı',
    // Add the rest of the 57 airports here
  ];

  final List<Map<String, dynamic>> _valizBoyutlari = [
    {'label': 'Küçük', 'icon': Icons.work},
    {'label': 'Orta', 'icon': Icons.shopping_bag},
    {'label': 'Büyük', 'icon': Icons.luggage},
  ];

  Future<void> _updateAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedAddress =
              '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
        });
      }
    } catch (e) {
      print('Error getting address from LatLng: $e');
    }
  }

  Future<void> _searchAddress(String address) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
          _updateAddressFromLatLng(_selectedLocation);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error searching address: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    final conn = await DatabaseHelper.connect();
    await conn.query(
      'INSERT INTO yolcu_olustur (inis_noktasi, valiz_boyutu, varis_noktasi, varis_noktasi_yazili, pnr, username, driver_username) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        _selectedInisNoktasi,
        _selectedValizBoyutu,
        '${_selectedLocation.latitude},${_selectedLocation.longitude}',
        _searchController.text,
        _pnrController.text,
        Provider.of<UserProvider>(context, listen: false).username,
        _selectedDriver,
      ],
    );
    await conn.close();
    print('Data saved to database');
  }

  Future<void> _fetchDrivers() async {
    final conn = await DatabaseHelper.connect();
    final result = await conn.query('''
      SELECT dl.driver_username, u.profile_image,
             ST_Distance_Sphere(POINT(dl.boylam, dl.enlem), POINT(27.1567, 38.2924)) AS distance
      FROM driver_locations dl
      JOIN users u ON dl.driver_username = u.username
      WHERE dl.driver_username NOT IN (SELECT driver_username FROM journeys)
      ORDER BY distance ASC
    ''');
    await conn.close();

    _drivers = result.map((row) {
      final distance = row['distance'];
      final time = (distance / 1000) / 60; // Assuming average speed of 60 km/h
      return {
        'username': row['driver_username'],
        'profile_image': row['profile_image'],
        'distance': (distance / 1000).toInt(), // Convert to kilometers
        'time': (time * 60).toInt(), // Convert to minutes
      };
    }).toList();

    if (_drivers.isNotEmpty) {
      _selectedDriver = _drivers.first['username'];
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: Provider.of<UserProvider>(context).fullname,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "İniş Noktası",
              style: TextStyle(fontSize: 16, color: AppStyles.textColor),
            ),
            DropdownButtonFormField<String>(
              value: _selectedInisNoktasi,
              items: _inisNoktalari
                  .map((inisNoktasi) => DropdownMenuItem(
                        value: inisNoktasi,
                        child: Text(inisNoktasi),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedInisNoktasi = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "İniş Noktası",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Valiz Boyutunuz",
              style: TextStyle(fontSize: 16, color: AppStyles.textColor),
            ),
            DropdownButtonFormField<String>(
              value: _selectedValizBoyutu,
              items: _valizBoyutlari
                  .map<DropdownMenuItem<String>>((valiz) => DropdownMenuItem<String>(
                        value: valiz['label'],
                        child: Row(
                          children: [
                            Icon(valiz['icon']),
                            const SizedBox(width: 10),
                            Text(valiz['label']),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValizBoyutu = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Valiz Boyutu",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Varış Noktası",
              style: TextStyle(fontSize: 16, color: AppStyles.textColor),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Adres Ara",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _searchAddress,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.buttonColor,
                    foregroundColor: AppStyles.buttonTextColor,
                  ),
                  onPressed: () async {
                    await _searchAddress(_searchController.text);
                    setState(() {});
                  },
                  child: const Text("Seç"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 300,
                        child: FlutterMap(
                          options: MapOptions(
                            center: _selectedLocation,
                            zoom: 13.0,
                            maxZoom: 18.0,
                            onTap: (tapPosition, point) {
                              setState(() {
                                _selectedLocation = point;
                                _updateAddressFromLatLng(_selectedLocation);
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation,
                                  builder: (ctx) => const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
            Text(
              "Seçilen Adres: $_selectedAddress",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              "PNR Numaranız",
              style: TextStyle(fontSize: 16, color: AppStyles.textColor),
            ),
            TextField(
              controller: _pnrController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "PNR Numarası",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sürücü Seçimi",
              style: TextStyle(fontSize: 16, color: AppStyles.textColor),
            ),
            DropdownButtonFormField<String>(
              value: _selectedDriver,
              items: _drivers
                  .map<DropdownMenuItem<String>>((driver) => DropdownMenuItem<String>(
                        value: driver['username'],
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(driver['profile_image']),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${driver['username']} - ${driver['distance']} km - ${driver['time']} dakika',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDriver = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Sürücü Seçimi",
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.buttonColor,
                  foregroundColor: AppStyles.buttonTextColor,
                ),
                onPressed: () async {
                  await _saveData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Yolculuk oluşturuldu!")),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KullaniciYolculuklar(),
                    ),
                  );
                },
                child: const Text("Yolculuk Oluştur"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Future<void> _selectVarisNoktasi() async {
    LatLng initialLocation = LatLng(39.9334, 32.8597); // Default location
    if (_selectedInisNoktasi != null) {
      initialLocation = await _getLatLngFromAddress(_selectedInisNoktasi!);
    }

    final selectedData = await showDialog(
      context: context,
      builder: (context) => _MapDialog(initialLocation: initialLocation),
    );

    if (selectedData != null && selectedData is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = selectedData['location'];
        _varisNoktasiController.text =
            '${selectedData['address']} (${selectedData['location'].latitude}, ${selectedData['location'].longitude})';
      });
    }
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error getting LatLng from address: $e');
    }
    return LatLng(39.9334, 32.8597);
  }
}

class _MapDialog extends StatefulWidget {
  final LatLng initialLocation;

  const _MapDialog({required this.initialLocation});

  @override
  __MapDialogState createState() => __MapDialogState();
}

class __MapDialogState extends State<_MapDialog> {
  late LatLng _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedAddress = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _updateAddressFromLatLng(_selectedLocation);
  }

  Future<void> _updateAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedAddress =
              '${placemarks.first.name}, ${placemarks.first.locality}';
        });
      }
    } catch (e) {
      print('Error getting address from LatLng: $e');
    }
  }

  Future<void> _searchAddress(String address) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
          _updateAddressFromLatLng(_selectedLocation);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error searching address: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Varış Noktası Seçin"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Adres Ara",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: _searchAddress,
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: FlutterMap(
                        options: MapOptions(
                          center: _selectedLocation,
                          zoom: 13.0,
                          maxZoom: 18.0,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                              _updateAddressFromLatLng(_selectedLocation);
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                builder: (ctx) => const Icon(Icons.location_on,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          Text(
            "Seçilen Adres: $_selectedAddress",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("İptal"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                'location': _selectedLocation,
                'address': _selectedAddress,
              },
            );
            setState(() {
              _selectedLocation = _selectedLocation;
            });
          },
          child: const Text("Seç"),
        ),
      ],
    );
  }
}
