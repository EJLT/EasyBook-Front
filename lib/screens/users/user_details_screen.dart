import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        businessName = reservationDetails!['business_name']; // Usar el nombre del negocio directamente
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

  // Cargar el nombre del negocio
  Future<void> _fetchBusinessName(int businessId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/businesses/$businessId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          businessName = json.decode(response.body)['name']; 
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener nombre del negocio: $e");
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
              ],
            ),
          ),
    );
  }
}