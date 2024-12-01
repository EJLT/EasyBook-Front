import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateReserveScreen extends StatefulWidget {
  final int businessId;
  final String businessName;

  const CreateReserveScreen(
      {super.key, required this.businessId, required this.businessName});

  @override
  _CreateReserveScreenState createState() => _CreateReserveScreenState();
}

class _CreateReserveScreenState extends State<CreateReserveScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _formattedDate;
  late String _formattedTime;

  @override
  void initState() {
    super.initState();
    _formattedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate); // Formateo de la fecha

    // Formateo de la hora sin segundos
    _formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _createReservation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Debug: Verificar el token
      print("Token: $token");

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/user/reservations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'business_id': widget.businessId.toString(),
          'date': _formattedDate,
          'time': _formattedTime, // La hora ahora no tiene segundos
        }),
      );

      // Depuración: Imprimir la respuesta
      print("Respuesta: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 201) {
        print("Reserva creada con éxito");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva creada con éxito")),
        );
        Navigator.pop(context);
      } else {
        print("Error al crear la reserva: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al crear la reserva")),
        );
      }
    } catch (e) {
      print("Error al crear la reserva: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear la reserva")),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyy-MM-dd')
            .format(_selectedDate); // Actualizar fecha formateada
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'; // Actualizar hora formateada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Crear Reserva en ${widget.businessName}"), // Mostrar el nombre del negocio
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Negocio: ${widget.businessName}",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text("Seleccionar Fecha: $_formattedDate"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectTime,
              child: Text("Seleccionar Hora: $_formattedTime"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createReservation,
              child: const Text("Crear Reserva"),
            ),
          ],
        ),
      ),
    );
  }
}
