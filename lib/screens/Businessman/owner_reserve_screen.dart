import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessReservationsScreen extends StatefulWidget {
  final int businessId;  // Recibimos el businessId para obtener las reservas

  BusinessReservationsScreen({required this.businessId});

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

  // Método para cargar las reservas
  Future<void> _loadReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/business-owner/businesses/${widget.businessId}/reservations'),
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
        title: Text('Reservas del Negocio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reservations.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Reserva #${reservation['id']}',
                        style: TextStyle(
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
