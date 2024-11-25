import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_reserve_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<dynamic> businesses = [];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token no encontrado");
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/businesses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          businesses = json.decode(response.body);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos los Negocios'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserReserveScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(businesses[index]['name']),
            subtitle: Text(businesses[index]['address']),
            onTap: () {
              // Navegar a detalles del negocio (opcional)
            },
          );
        },
      ),
    );
  }
}
