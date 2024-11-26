import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserUpdateScreen extends StatefulWidget {
  final int reservationId;
  final String currentDate;
  final String currentTime;

  const UserUpdateScreen({
    super.key,
    required this.reservationId,
    required this.currentDate,
    required this.currentTime,
  });

  @override
  _UserUpdateScreenState createState() => _UserUpdateScreenState();
}

class _UserUpdateScreenState extends State<UserUpdateScreen> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.currentDate);
    _timeController = TextEditingController(text: widget.currentTime);
  }

  // Lógica para actualizar la reserva
  Future<void> _updateReservation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token no encontrado");
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final body = json.encode({
      'date': _dateController.text,
      'time': _timeController.text,
    });

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/user/reservations/${widget.reservationId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final updatedReservation = json.decode(response.body);
        print("Reserva actualizada: $updatedReservation");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva actualizada correctamente')),
        );
        
        Navigator.pop(context); // Volver a la pantalla anterior
      } else {
        print("Error al actualizar la reserva: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la reserva')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actualizar Reserva")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Actualizar la reserva #${widget.reservationId}", style: const TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Fecha",
                hintText: "Selecciona una fecha",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    // Mostrar un DatePicker para seleccionar la fecha
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_dateController.text),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: "Hora",
                hintText: "Selecciona una hora",
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    // Mostrar un TimePicker para seleccionar la hora
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.parse("2000-01-01 ${_timeController.text}:00")),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _timeController.text = pickedTime.format(context);
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateReservation,
              child: const Text("Actualizar Reserva"),
            ),
          ],
        ),
      ),
    );
  }
}
