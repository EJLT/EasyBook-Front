import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserReserveScreen extends StatefulWidget {
  const UserReserveScreen({super.key});

  @override
  _UserReserveScreenState createState() => _UserReserveScreenState();
}

class _UserReserveScreenState extends State<UserReserveScreen> {
  List<dynamic> reservations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/reservations'), 
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          reservations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error al cargar reservas: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error de conexión: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Reservas")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Reserva en ${reservations[index]['business_name']}'),
                      subtitle: Text('Estado: ${reservations[index]['status']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsScreen(
                              reservationId: reservations[index]['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
