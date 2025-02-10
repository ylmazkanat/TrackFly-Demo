import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = ''; // Kullanıcı adı
  String _fullname = ''; // Tam isim
  String _userId = ''; // Kullanıcı ID'si
  bool _isActive = false; // Aktivasyon durumu
  String? _profileImageUrl; // Profil resmi URL'si

  String get username => _username;
  String get fullname => _fullname;
  String get userId => _userId; // Yeni ID Getter
  bool get isActive => _isActive; // Aktivasyon durumu Getter
  String? get profileImageUrl => _profileImageUrl; // Profil resmi URL'si Getter

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setFullname(String fullname) {
    _fullname = fullname;
    notifyListeners();
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setIsActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void setProfileImageUrl(String? url) { // Profil resmi URL'si Setter
    _profileImageUrl = url;
    notifyListeners();
  }
}
