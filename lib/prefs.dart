import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String getString(String key, String defaultVal) {
    return _sharedPrefs.getString(key) ?? defaultVal;
  }

  int getInt(String key, int defaultVal) {
    return _sharedPrefs.getInt(key) ?? defaultVal;
  }

  bool getBool(String key, bool defaultVal) {
    return _sharedPrefs.getBool(key) ?? defaultVal;
  }

  void setString(String key, String val) {
    _sharedPrefs.setString(key, val);
  }

  void setInt(String key, int val) {
    _sharedPrefs.setInt(key, val);
  }

  void setBool(String key, bool val) {
    _sharedPrefs.setBool(key, val);
  }

}

final sharedPrefs = SharedPrefs();