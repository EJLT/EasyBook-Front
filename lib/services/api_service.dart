import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Obtén la IP local según el entorno
  String getBaseUrl() {
    // Emulador (Android)
    if (isEmulator()) {
      return 'http://10.0.2.2:8000';
    }

    // Para dispositivos físicos, usa la IP local de tu máquina de desarrollo
    return 'http://localhost:8000';
  }

  bool isEmulator() {
    return false;
  }

  // Método para realizar el login y guardar el ownerId y el token
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${getBaseUrl()}/api/login'); // Usamos la baseUrl

    // Realiza la solicitud POST para iniciar sesión
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Si el login es exitoso, procesamos la respuesta
      final data = json.decode(response.body);

      // Extraemos el role, ownerId y token de la respuesta
      final ownerId = data['owner_id'];
      final token = data['token'];
      final role = data['role']; // Suponiendo que el backend devuelve el rol

      // Guardamos el ownerId y el token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ownerId', ownerId.toString());
      await prefs.setString('token', token);

      return {
        'ownerId': ownerId,
        'token': token,
        'role': role, // Devolvemos también el role
      };
    } else {
      // Si el login falla, muestra un mensaje de error
      print('Error al iniciar sesión');
      throw Exception('Login failed');
    }
  }
}
