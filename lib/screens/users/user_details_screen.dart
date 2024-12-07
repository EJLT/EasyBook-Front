import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_update_screen.dart';

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
        Uri.parse(
            'http://localhost:8000/api/user/reservations/${widget.reservationId}'),
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

  // Actualizar la reserva
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
        Uri.parse(
            'http://localhost:8000/api/user/reservations/${widget.reservationId}'),
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
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(0, 110, 143, 140), // Fondo transparente
        elevation: 4.0, // Sombra
        title: Row(
          children: [
            Image.asset(
              'assets/images/EasyBook.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              "EasyBook",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo que ocupa toda la pantalla
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/recepcion.jpg'),
                fit: BoxFit.cover, // La imagen cubre todo el fondo
                colorFilter: ColorFilter.mode(
                  Colors.black54, // Oscurece el fondo
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Contenido de la pantalla que se desplaza
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Información de la Reserva",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Negocio:", businessName!),
                  _buildDetailRow("Estado:", reservationDetails!['status']),
                  _buildDetailRow(
                      "Fecha:", reservationDetails!['reservation_date']),
                  _buildDetailRow(
                      "Hora:", reservationDetails!['reservation_time']),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _updateReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text("Actualizar"),
                      ),
                      ElevatedButton(
                        onPressed: _deleteReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Método para construir las filas de los detalles
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
