import 'package:shared_preferences/shared_preferences.dart';

Future<T> read<T>(String key) async {
  final prefs = await SharedPreferences.getInstance();
  late var value;
  switch (T) {
    case int:
      value = prefs.getInt(key) ?? 0;
      break;
    case String:
      value = prefs.getString(key) ?? '';
      break;
    case bool:
      value = prefs.getBool(key) ?? false;
      break;
    default:
      value = false;
      break;
  }
  return value;
}

Future save(String key, value) async {
  final prefs = await SharedPreferences.getInstance();

  switch (value.runtimeType) {
    case int:
      prefs.setInt(key, value);
      break;
    case String:
      prefs.setString(key, value);
      break;
    case bool:
      prefs.setBool(key, value);
      break;
  }
}
