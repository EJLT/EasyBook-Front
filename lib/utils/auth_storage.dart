// auth_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // Guardar el token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Obtener el token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Guardar el ownerId
  static Future<void> saveOwnerId(String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ownerId', ownerId);
  }

  // Obtener el ownerId
  static Future<String?> getOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ownerId');
  }

  // Eliminar el token y el ownerId (cuando el usuario cierre sesión)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('ownerId');
  }
}
