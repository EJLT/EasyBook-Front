import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_update_screen.dart'; // Asegúrate de importar la pantalla de actualización

class UserDetailsScreen extends StatefulWidget {
  final int reservationId;

  const UserDetailsScreen({super.key, required this.reservationId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? reservationDetails;
  String? businessName;

  @override
  void initState() {
    super.initState();
    _loadReservationDetails();
  }

  // Cargar los detalles de la reserva
  Future<void> _loadReservationDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/reservations/${widget.reservationId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          reservationDetails = json.decode(response.body);
          businessName = reservationDetails!['business_name'];
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Actualizar la reserva (esto lo redirige a la pantalla de actualización)
  Future<void> _updateReservation() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserUpdateScreen(
          reservationId: widget.reservationId,
          currentDate: reservationDetails!['reservation_date'],
          currentTime: reservationDetails!['reservation_time'],
        ),
      ),
    );
  }

  // Eliminar la reserva
  Future<void> _deleteReservation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/user/reservations/${widget.reservationId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("Reserva eliminada");
        Navigator.pop(context); // Volver a la pantalla anterior
      } else {
        print("Error al eliminar la reserva: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al eliminar la reserva: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Información de la Reserva")),
      body: reservationDetails == null || businessName == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Detalles #${reservationDetails!['id']}", style: const TextStyle(fontSize: 24)),
                  Text("Estado: ${reservationDetails!['status']}", style: const TextStyle(fontSize: 18)),
                  Text("Negocio: $businessName", style: const TextStyle(fontSize: 18)),
                  Text("Fecha: ${reservationDetails!['reservation_date']}", style: const TextStyle(fontSize: 18)),
                  Text("Hora: ${reservationDetails!['reservation_time']}", style: const TextStyle(fontSize: 18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _updateReservation,
                        child: const Text("Actualizar"),
                      ),
                      ElevatedButton(
                        onPressed: _deleteReservation,
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
