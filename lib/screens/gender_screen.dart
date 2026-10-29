// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';

import '../api.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});
  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final c = TextEditingController();
  Color bg = Colors.white;
  String msg = '';

  Future<void> predecir() async {
    try {
      final d = await getJson(
        'https://api.genderize.io/?name=${Uri.encodeComponent(c.text.trim())}',
      );
      setState(() {
        if (d['gender'] == 'male') {
          bg = Colors.blue.shade300;
          msg = 'Masculino';
        } else if (d['gender'] == 'female') {
          bg = Colors.pink.shade200;
          msg = 'Femenino';
        } else {
          bg = Colors.grey.shade300;
          msg = 'No se pudo determinar';
        }
      });
    } catch (e) {
      setState(() => msg = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Predecir género')),
    body: Container(
      color: bg,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: c,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: predecir, child: const Text('Predecir')),
          const SizedBox(height: 24),
          Text(msg, style: const TextStyle(fontSize: 28)),
        ],
      ),
    ),
  );
}
