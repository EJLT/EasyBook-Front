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
  Map<String, int> _stats = {}; // Para almacenar las estadísticas

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadStatistics(); // Cargar estadísticas también
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
        print(reservations);
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

  Future<void> _confirmAllReservations() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    print("Token no encontrado");
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/owner/businesses/${widget.businessId}/reservations/confirm-all'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      _loadReservations(); // Recargar las reservas después de confirmar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todas las reservas han sido confirmadas.")),
      );
    } else {
      print("Error al confirmar todas las reservas: ${response.statusCode}");
    }
  } catch (e) {
    print("Excepción al confirmar todas las reservas: $e");
  }
}


  // Función para cargar estadísticas
  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/owner/reservations/stats/${widget.businessId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> stats = json.decode(response.body);
        setState(() {
          _stats = stats.map((key, value) => MapEntry(key, value.toInt())); 
        });
      } else {
        print("Error al cargar estadísticas: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al cargar estadísticas: $e");
    }
  }

  // Función para confirmar reserva
  Future<void> _confirmReservation(int reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/owner/reservations/$reservationId/confirm'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _loadReservations();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva confirmada.")),
        );
      } else {
        print("Error al confirmar reserva: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al confirmar reserva: $e");
    }
  }

  // Función para cancelar reserva
  Future<void> _cancelReservation(int reservationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/owner/reservations/$reservationId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _loadReservations(); // Recargar las reservas después de cancelar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva cancelada.")),
        );
      } else {
        print("Error al cancelar reserva: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al cancelar reserva: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.businessId != null ? 'Reservas del Negocio' : 'Todas las Reservas'),
        backgroundColor: Colors.blueAccent,
        actions: [
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Confirmar todas las reservas',
                onPressed: _confirmAllReservations,
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  // Mostrar estadísticas
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Estadísticas del Negocio"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _stats.entries.map((entry) {
                            return Text('${entry.key}: ${entry.value}');
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reservations.isEmpty
            ? const Center(child: Text('No hay reservas aún.'))
            : ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  final status = reservation['status']; // Estado de la reserva

                  // Determina el color del estado según su valor
                  Color statusColor;
                  switch (status) {
                    case 'confirmada':
                      statusColor = Colors.green;
                      break;
                    case 'cancelada':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.orange; 
                  }

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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha: ${reservation['date']} - Hora: ${reservation['time']}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          'Usuario: ${reservation['user_name']}', // Agregar el nombre del usuario
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _confirmReservation(reservation['id']),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _cancelReservation(reservation['id']),
        ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}