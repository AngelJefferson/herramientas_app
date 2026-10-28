// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import 'screens/gender_screen.dart';
import 'screens/user_screen.dart';
import 'screens/universities_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/wordpress_screen.dart';
import 'screens/about_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Caja de Herramientas',
        theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
        home: const Home(),
      );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, Widget)>[
      ('Género', Icons.wc, const GenderScreen()),
      ('Persona', Icons.person, const UserScreen()),
      ('Universidades', Icons.school, const UniversitiesScreen()),
      ('Clima RD', Icons.wb_sunny, const WeatherScreen()),
      ('Pokémon', Icons.catching_pokemon, const PokemonScreen()),
      ('Noticias', Icons.article, const WordpressScreen()),
      ('Acerca de', Icons.info, const AboutScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Caja de Herramientas')),
      body: Column(children: [
        Image.asset('assets/toolbox.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(12),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final i in items)
                Card(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => i.$3)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(i.$2, size: 40),
                      const SizedBox(height: 8),
                      Text(i.$1),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}