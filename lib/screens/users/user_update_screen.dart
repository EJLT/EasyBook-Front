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
        Uri.parse(
            'http://localhost:8000/api/user/reservations/${widget.reservationId}'),
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
          const SnackBar(content: Text('Reserva actualizada correctamente')),
        );

        Navigator.pop(context); // Volver a la pantalla anterior
      } else {
        print("Error al actualizar la reserva: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar la reserva')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 79, 98, 184),
        elevation: 4.0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/EasyBook.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'EasyBook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/comercio.jpg'), // Fondo personalizado
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.3), // Fondo translúcido
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Actualizar Reserva',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campos de texto con validación
                      TextField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: "Fecha",
                          hintText: "Selecciona una fecha",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.parse(_dateController.text),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateController.text = pickedDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0];
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: "Hora",
                          hintText: "Selecciona una hora",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    DateTime.parse(
                                        "2000-01-01 ${_timeController.text}:00")),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _timeController.text =
                                      "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(251, 114, 118, 126),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          minimumSize: const Size(300, 50),
                        ),
                        child: const Text("Actualizar Reserva"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
