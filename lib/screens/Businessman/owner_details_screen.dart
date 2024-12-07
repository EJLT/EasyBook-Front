import 'dart:convert';
import 'package:flutter/material.dart';
import '../Businessman/owner_update_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'owner_reserve_screen.dart';
import 'dart:ui';

class BusinessDetailsScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailsScreen({super.key, required this.businessId});

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
        Uri.parse(
            'http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<void> _deleteBusiness() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.delete(
        Uri.parse(
            'http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio eliminado con éxito.")),
        );
        Navigator.pop(context);
      } else {
        print("Error al eliminar negocio: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al eliminar el negocio.")),
        );
      }
    } catch (e) {
      print("Excepción al eliminar negocio: $e");
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content:
              const Text("¿Estás seguro de que deseas eliminar este negocio?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBusiness();
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
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
      body: Stack(
        children: [
          // Imagen de fondo difuminada
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/boutique.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : businessDetails == null
                  ? const Center(
                      child: Text(
                        'Error al cargar los detalles del negocio',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título del negocio
                          Center(
                            child: Text(
                              businessDetails!['name'] ??
                                  'Nombre no disponible',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Caja de información
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 255, 255, 255)
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(
                                    Icons.location_on,
                                    businessDetails!['address'] ??
                                        'Dirección no disponible'),
                                const SizedBox(height: 10),
                                _infoRow(
                                    Icons.email,
                                    businessDetails!['email'] ??
                                        'No hay email disponible'),
                                if (businessDetails!['phone'] != null) ...[
                                  const SizedBox(height: 10),
                                  _infoRow(
                                      Icons.phone, businessDetails!['phone']),
                                ],
                                const SizedBox(height: 20),
                                // Botones
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OwnerUpdateScreen(
                                              businessId: widget.businessId,
                                              currentName:
                                                  businessDetails!['name'],
                                              currentAddress:
                                                  businessDetails!['address'],
                                              currentPhone:
                                                  businessDetails!['phone'],
                                              currentEmail:
                                                  businessDetails!['email'],
                                              currentCategory:
                                                  businessDetails!['category'],
                                              updateBusinessList:
                                                  _loadBusinessDetails,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Actualizar"),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showDeleteConfirmation,
                                      icon: const Icon(Icons.delete),
                                      label: const Text("Eliminar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BusinessReservationsScreen(
                                      businessId: widget.businessId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              child: const Text('Ver Reservas'),
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
