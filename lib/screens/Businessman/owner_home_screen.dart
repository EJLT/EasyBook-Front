import 'dart:convert'; // Para poder decodificar la respuesta JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Businessman/owner_details_screen.dart';
import '../Businessman/owner_reserve_screen.dart';  

class OwnerHomeScreen extends StatefulWidget {
  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  List<dynamic> _businesses = [];
  String ownerId = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerId();
  }

  Future<void> _loadOwnerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ownerId = prefs.getString('ownerId') ?? '';
    });

    if (ownerId.isNotEmpty) {
      _loadBusinessData();
    }
  }

  Future<void> _loadBusinessData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/owner/businesses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> businesses = json.decode(response.body);
        setState(() {
          _businesses = businesses;
        });
      } else {
        print("Error: Código de estado ${response.statusCode}");
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Excepción al cargar los negocios: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Navegar a la pantalla de detalles de un negocio
  void _navigateToBusinessDetails(int businessId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailsScreen(businessId: businessId),
      ),
    );
  }

  // Navegar a la pantalla de reservas del negocio
  void _navigateToBusinessReservations(int businessId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessReservationsScreen(businessId: businessId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel del Propietario', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Botón para añadir un nuevo negocio
          IconButton(
            icon: Icon(Icons.add_business),
            tooltip: 'Añadir Nuevo Negocio',
            onPressed: () {
              Navigator.pushNamed(context, '/create_business');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Negocios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _businesses.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _businesses.length,
                      itemBuilder: (context, index) {
                        final business = _businesses[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets .all(16),
                            title: Text(
                              business['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              business['address'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            onTap: () => _navigateToBusinessDetails(business['id']),
                            trailing: IconButton(
                              icon: Icon(Icons.calendar_today),
                              tooltip: 'Reservas',
                              onPressed: () {
                                _navigateToBusinessReservations(business['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}