// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Acerca de')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircleAvatar(radius: 70, backgroundImage: AssetImage('assets/yo.jpg')),
            const SizedBox(height: 16),
            const Text('Angel Jefferson Sánchez Ventura', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Estudiante de Desarrollo de Software, ITLA'),
            const SizedBox(height: 16),
            const ListTile(leading: Icon(Icons.email), title: Text('tucorreo@ejemplo.com')),
            const ListTile(leading: Icon(Icons.phone), title: Text('809-000-0000')),
            const ListTile(leading: Icon(Icons.link), title: Text('linkedin.com/in/tuperfil')),
          ]),
        ),
      );
}