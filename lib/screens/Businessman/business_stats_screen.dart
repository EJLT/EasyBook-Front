import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessStatsScreen extends StatefulWidget {
  @override
  _BusinessStatsScreenState createState() => _BusinessStatsScreenState();
}

class _BusinessStatsScreenState extends State<BusinessStatsScreen> {
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  // Función para obtener las estadísticas del backend
  Future<void> fetchStats() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/businesses//stats/{businessId}'));

    if (response.statusCode == 200) {
      setState(() {
        stats = json.decode(response.body);
      });
    } else {
      // Manejo de errores
      throw Exception('Failed to load stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas del Negocio'),
      ),
      body: stats.isEmpty
          ? Center(child: CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total de Reservas: ${stats['total']}'),
                  Text('Reservas Confirmadas: ${stats['confirmed']}'),
                  Text('Reservas Canceladas: ${stats['cancelled']}'),
                  Text('Reservas Pendientes: ${stats['pending']}'),
                ],
              ),
            ),
    );
  }
}
