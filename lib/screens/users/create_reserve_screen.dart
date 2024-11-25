import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateReserveScreen extends StatefulWidget {
  final int businessId;

  const CreateReserveScreen({required this.businessId, super.key});

  @override
  _CreateReserveScreenState createState() => _CreateReserveScreenState();
}

class _CreateReserveScreenState extends State<CreateReserveScreen> {
  Map<String, List<String>> schedule = {};
  String selectedDate = "";
  String selectedTime = "";

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost/api/businesses/${widget.businessId}/schedule'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          schedule = Map<String, List<String>>.from(json.decode(response.body));
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  Future<void> _createReservation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/user/reservations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'business_id': widget.businessId,
          'date': selectedDate,
          'time': selectedTime,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva creada exitosamente")),
        );
        Navigator.pop(context);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Reserva')),
      body: schedule.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: schedule.keys.length,
                    itemBuilder: (context, index) {
                      final date = schedule.keys.elementAt(index);
                      final times = schedule[date]!;
                      return ExpansionTile(
                        title: Text(date),
                        children: times.map((time) {
                          final isAvailable = time != "Ocupado";
                          return ListTile(
                            title: Text(
                              time,
                              style: TextStyle(
                                color: isAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                            enabled: isAvailable,
                            onTap: isAvailable
                                ? () {
                                    setState(() {
                                      selectedDate = date;
                                      selectedTime = time;
                                    });
                                  }
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                if (selectedDate.isNotEmpty && selectedTime.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _createReservation,
                      child: const Text("Crear Reserva"),
                    ),
                  ),
              ],
            ),
    );
  }
}
