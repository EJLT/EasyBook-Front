import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessReservationsScreen extends StatefulWidget {
  final int? businessId; 

  const BusinessReservationsScreen({super.key, this.businessId});

  @override
  _BusinessReservationsScreenState createState() => _BusinessReservationsScreenState();
}

class _BusinessReservationsScreenState extends State<BusinessReservationsScreen> {
  List<dynamic> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

 Future<void> _loadReservations() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    print("Token no encontrado");
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  try {
    
    final url = widget.businessId != null
        ? 'http://localhost:8000/api/owner/businesses/${widget.businessId}/reservations'
        : 'http://localhost:8000/api/owner/all-reservations';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> reservations = json.decode(response.body);
      setState(() {
        _reservations = reservations;
      });
    } else {
      print("Error: Código de estado ${response.statusCode}");
      Navigator.pushReplacementNamed(context, '/login');
    }
  } catch (e) {
    print("Excepción al cargar las reservas: $e");
    Navigator.pushReplacementNamed(context, '/login');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.businessId != null
            ? 'Reservas del Negocio'
            : 'Todas las Reservas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reservations.isEmpty
            ? const Center(
                child: Text(
                  'No hay reservas aún.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Reserva #${reservation['id']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Fecha: ${reservation['date']} - Hora: ${reservation['time']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
