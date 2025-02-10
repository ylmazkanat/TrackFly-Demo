import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackfly/pages/surucu/surucu_profil.dart';
import '../genel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '/db/db_helper.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const Header({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(140);
}

class _HeaderState extends State<Header> {
  String? userId;
  Position? lastPosition;
  Timer? positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  @override
  void dispose() {
    positionUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullname = Provider.of<UserProvider>(context).fullname;
    final profileImageUrl = Provider.of<UserProvider>(context).profileImageUrl; // Get profile image URL
    final isActive = Provider.of<UserProvider>(context).isActive;

    return AppBar(
      backgroundColor: AppStyles.primaryColor, // Use primary color
      elevation: 4,
      toolbarHeight: 140,
      leading: widget.onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppStyles.iconColorWhite),
              onPressed: widget.onBackPressed,
            )
          : null,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SurucuProfil()),
              );
            },
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppStyles.avatarBackgroundColor,
              child: CircleAvatar(
                radius: 33,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage('lib/images/profil.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColorWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Hoş geldiniz!",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppStyles.iconColorWhite.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              Provider.of<UserProvider>(context, listen: false).setIsActive(value);
              if (value) {
                _startPositionUpdateTimer();
              } else {
                positionUpdateTimer?.cancel();
              }
            },
            activeColor: AppStyles.activeSwitchColor,
            inactiveThumbColor: AppStyles.iconColorWhite,
            inactiveTrackColor: AppStyles.inactiveSwitchTrackColor,
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled) || !isActive) {
                  return Colors.white; // White border when inactive
                }
                return null; // No border when active
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startPositionUpdateTimer() {
    _updatePosition();
    positionUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updatePosition();
    });
  }

  void _getUserId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      userId = userProvider.username;
    });
  }

  Future<void> _updatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (lastPosition != null) {
        double distanceInMeters = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters > 100) {
          await _updateDatabase(userId!, position.latitude, position.longitude);
          lastPosition = position;
        } else {
          print("Konum değişmedi, güncelleme yapılmadı.");
        }
      } else {
        await _updateDatabase(userId!, position.latitude, position.longitude);
        lastPosition = position;
      }
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

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
          [latitude, longitude, driverUsername], // Doğru sıra
        );
      } else {
        // driver_username yoksa yeni bir satır ekle
        await conn.query(
          '''
          INSERT INTO driver_locations (driver_username, enlem, boylam, timestamp) 
          VALUES (?, ?, ?, NOW())
          ''',
          [driverUsername, latitude, longitude], // Doğru sıra
        );
      }

      await conn.close();
    } catch (e) {
      print("Veritabanı hatası: $e");
    }
  }
}
