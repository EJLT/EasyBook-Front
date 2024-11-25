import 'dart:convert'; // Para decodificar la respuesta JSON
import 'package:flutter/material.dart';
import '../Businessman/owner_update_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
   // Función para actualizar la lista de negocios (recargando los datos)
  void updateBusinessList() {
    _loadBusinessDetails();
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
        Uri.parse('http://localhost:8000/api/owner/businesses/${widget.businessId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Negocio eliminado con éxito.")),
        );
        Navigator.pop(context); // Vuelve a la pantalla anterior
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
          content: const Text("¿Estás seguro de que deseas eliminar este negocio?"),
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
        title: Text(businessDetails?['name'] ?? 'Detalles del Negocio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : businessDetails == null
              ? const Center(child: Text('Error al cargar los detalles del negocio'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessDetails!['name'] ?? 'Nombre no disponible',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              businessDetails!['address'] ?? 'Dirección no disponible',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              businessDetails!['email'] ?? 'No hay email disponible',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (businessDetails!['phone'] != null)
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              businessDetails!['phone'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OwnerUpdateScreen(
                                    businessId: widget.businessId,
                                    currentName: businessDetails!['name'],
                                    currentAddress: businessDetails!['address'],
                                    currentPhone: businessDetails!['phone'],
                                    currentEmail: businessDetails!['email'],
                                    updateBusinessList: updateBusinessList,
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

                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          child: const Text('Volver'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
