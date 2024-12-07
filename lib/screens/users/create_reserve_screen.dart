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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(0, 110, 143, 140), // Fondo del AppBar
        elevation: 4.0, // Sombra del AppBar
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
                color: Color.fromARGB(255, 0, 0, 0), // Texto en negro
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo que cubre toda la pantalla
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/paisaje.jpg'),
                fit: BoxFit.cover, // La imagen cubre todo el fondo
                alignment: Alignment.center, // Centra la imagen
              ),
            ),
          ),
          // Contenido de la pantalla que se desplaza
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la pantalla
                  Text(
                    "Negocio: ${widget.businessName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Texto blanco
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón para seleccionar fecha
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.blueGrey
                          : Colors.blueAccent, // Cambia el color según el modo
                      foregroundColor: isDarkMode
                          ? Colors.white
                          : Colors.black, // Color del texto según el modo
                    ),
                    child: Text("Seleccionar Fecha: $_formattedDate"),
                  ),
                  const SizedBox(height: 20),
                  // Botón para seleccionar hora
                  ElevatedButton(
                    onPressed: _selectTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.blueGrey
                          : Colors.blueAccent, // Cambia el color según el modo
                      foregroundColor: isDarkMode
                          ? Colors.white
                          : Colors.black, // Color del texto según el modo
                    ),
                    child: Text("Seleccionar Hora: $_formattedTime"),
                  ),
                  const SizedBox(height: 20),
                  // Botón para crear reserva
                  ElevatedButton(
                    onPressed: _createReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.greenAccent
                          : Colors.green, // Cambia el color según el modo
                      foregroundColor: isDarkMode
                          ? Colors.black
                          : Colors.white, // Color del texto según el modo
                    ),
                    child: const Text("Crear Reserva"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
