// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import '../api.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<dynamic> f = getJson('https://randomuser.me/api/?results=1');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Persona aleatoria')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => f = getJson('https://randomuser.me/api/?results=1')),
          child: const Icon(Icons.refresh),
        ),
        body: FutureBuilder(
          future: f,
          builder: (_, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return Center(child: Text('${s.error}'));
            final u = s.data['results'][0];
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(radius: 60, backgroundImage: NetworkImage(u['picture']['large'])),
                const SizedBox(height: 16),
                Text('Nombre: ${u['name']['first']}', style: const TextStyle(fontSize: 20)),
                Text('Apellido: ${u['name']['last']}', style: const TextStyle(fontSize: 20)),
                Text('Nacimiento: ${u['dob']['date'].toString().substring(0, 10)}'),
                Text('Edad: ${u['dob']['age']} años'),
              ]),
            );
          },
        ),
      );
}