import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';


class BusinessScheduleScreen extends StatefulWidget {
  final int businessId;

  BusinessScheduleScreen({required this.businessId});

  @override
  _BusinessScheduleScreenState createState() => _BusinessScheduleScreenState();
}

class _BusinessScheduleScreenState extends State<BusinessScheduleScreen> {
  List<dynamic> schedule = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/business/${widget.businessId}/schedule/${selectedDate.toIso8601String().split("T")[0]}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        schedule = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Horarios Disponibles")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2020, 01, 01),
            lastDay: DateTime.utc(2030, 12, 31),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
              _loadSchedule();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final scheduleItem = schedule[index];
                return ListTile(
                  title: Text('${scheduleItem['time']}'),
                  tileColor: scheduleItem['is_booked'] ? Colors.grey : Colors.white,
                  onTap: scheduleItem['is_booked'] ? null : () {
                    // Lógica para reservar
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
