// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../api.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});
  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final c = TextEditingController();
  final player = AudioPlayer();
  Map? p;
  String? error;

  Future<void> buscar() async {
    try {
      final d = await getJson('https://pokeapi.co/api/v2/pokemon/${c.text.trim().toLowerCase()}');
      setState(() { p = d; error = null; });
      await player.play(UrlSource(d['cries']['latest']));
    } catch (_) {
      setState(() { p = null; error = 'Pokémon no encontrado'; });
    }
  }

  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pokémon')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(controller: c, decoration: InputDecoration(
            labelText: 'Nombre del Pokémon',
            suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: buscar))),
          if (error != null) Text(error!),
          if (p != null) ...[
            Image.network(p!['sprites']['other']['official-artwork']['front_default'], height: 220),
            Text(p!['name'].toString().toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26)),
            Text('Experiencia base: ${p!['base_experience']}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Habilidades:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (final a in p!['abilities']) Text('• ${a['ability']['name']}'),
            TextButton.icon(
              onPressed: () => player.play(UrlSource(p!['cries']['latest'])),
              icon: const Icon(Icons.volume_up), label: const Text('Reproducir sonido')),
          ],
        ]),
      );
}