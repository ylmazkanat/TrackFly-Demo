import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '/db/db_helper.dart';
import 'package:provider/provider.dart';
import '../genel/user_provider.dart';

class KonumGuncelle {
  Timer? positionUpdateTimer;
  MapController mapController = MapController();
  Position? currentPosition;  // Nullable olarak tanımlandı
  String? userId;
  bool showNotification = false; // Bildirim göstermek için

  KonumGuncelle(BuildContext context) {
    _getUserId(context);
    _checkAndRequestLocationPermission(context);
    _startPositionUpdateTimer(context); // Her 5 dakikada bir konumu güncelle
  }

  // Kullanıcı ID'sini al
  void _getUserId(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.username;
  }

  // Konum izni kontrolü
  Future<void> _checkAndRequestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _updatePosition(context); // Konum alındığında bir kez güncelle
    } else {
      print('Konum izni verilmedi');
    }
  }

  // Konumu ve veritabanını periyodik olarak güncelle
  void _startPositionUpdateTimer(BuildContext context) {
    positionUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updatePosition(context); // Her 5 dakikada bir konum güncelleme
    });
  }

  // Konum güncelle ve veritabanına gönder
  Future<void> _updatePosition(BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition = position;  // Nullable olduğu için, null kontrolü gerekmez

      // Haritanın merkezini yeni konuma ayarla
      mapController.move(LatLng(position.latitude, position.longitude), 14);

      // Veritabanına gönder
      if (userId != null) {
        await _updateDatabase(userId!, position.latitude, position.longitude);
        _showNotification(context); // Bildirimi göster
      }
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  // driver_locations tablosunu güncelle
  Future<void> _updateDatabase(String driverUsername, double latitude, double longitude) async {
    try {
      final conn = await DatabaseHelper.connect();

      // driver_username mevcut mu kontrol et
      var result = await conn.query(
        'SELECT * FROM driver_locations WHERE driver_username = ?',
        [driverUsername],
      );

      if (result.isNotEmpty) {
        // driver_username mevcutsa güncelle
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
        // driver_username yoksa yeni bir satır ekle
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

  // Bildirimi göster ve 5 saniye sonra gizle
  void _showNotification(BuildContext context) {
    showNotification = true;
    Future.delayed(const Duration(seconds: 5), () {
      showNotification = false;
    });
  }

  // Konumu güncellemek için butona tıklama işlemi
  void _onUpdatePositionPressed(BuildContext context) {
    if (currentPosition != null) {
      _updateDatabase(userId!, currentPosition!.latitude, currentPosition!.longitude);
      _showNotification(context); // Bildirimi göster
    }
  }
}
