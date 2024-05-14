import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'US Public Holidays',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PublicHolidaysScreen(),
    );
  }
}

class PublicHolidaysScreen extends StatefulWidget {
  const PublicHolidaysScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PublicHolidaysScreenState createState() => _PublicHolidaysScreenState();
}

class _PublicHolidaysScreenState extends State<PublicHolidaysScreen> {
  int selectedYear = DateTime.now().year;
  List<dynamic> publicHolidays = [];

  Future<void> fetchPublicHolidays(int year) async {
    final response = await http.get(
      Uri.parse('https://date.nager.at/api/v2/publicholidays/$selectedYear/US'),
    );

    if (response.statusCode == 200) {
      setState(() {
        publicHolidays = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load public holidays');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPublicHolidays(selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('US Public Holidays'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Select Year: '),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(
                  10,
                  (index) => DropdownMenuItem<int>(
                    value: DateTime.now().year - index,
                    child: Text((DateTime.now().year - index).toString()),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                    fetchPublicHolidays(selectedYear);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: publicHolidays.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(publicHolidays[index]['localName']),
                  subtitle: Text(publicHolidays[index]['date']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
