import 'dart:convert'; // Para decodificar la respuesta JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final int businessId;

  BusinessDetailsScreen({required this.businessId});

  @override
  _BusinessDetailsScreenState createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  Map<String, dynamic>? businessDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  // Método para cargar los detalles del negocio desde el backend
  Future<void> _loadBusinessDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          businessDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: Código de estado ${response.statusCode}");
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Excepción al cargar los detalles del negocio: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(businessDetails?['name'] ?? 'Detalles del Negocio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras espera los datos
          : businessDetails == null
              ? Center(child: Text('Error al cargar los detalles del negocio'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del negocio
                      Text(
                        businessDetails!['name'] ?? 'Nombre no disponible',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      // Dirección del negocio
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              businessDetails!['address'] ?? 'Dirección no disponible',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Email del negocio con icono
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              businessDetails!['email'] ?? 'No hay email disponible',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Teléfono del negocio
                      if (businessDetails!['phone'] != null)
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              businessDetails!['phone'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      SizedBox(height: 20),

                      // Botón para volver
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          child: Text('Volver'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
