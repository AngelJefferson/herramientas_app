// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});
  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final c = TextEditingController(text: 'Dominican Republic');
  List data = [];
  bool loading = false;
  String? error;

  Future<void> buscar() async {
    setState(() { loading = true; error = null; });
    try {
      final d = await getJson('https://adamix.net/proxy.php?country=${Uri.encodeQueryComponent(c.text.trim())}');
      data = d is List ? d : [];
    } catch (e) {
      error = '$e';
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Universidades')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: c, decoration: const InputDecoration(labelText: 'País (en inglés)'))),
              IconButton(onPressed: buscar, icon: const Icon(Icons.search)),
            ]),
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null) Text(error!),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final u = data[i];
                final web = (u['web_pages'] as List).isNotEmpty ? u['web_pages'][0] : null;
                final dom = (u['domains'] as List).isNotEmpty ? u['domains'][0] : '-';
                return ListTile(
                  title: Text(u['name']),
                  subtitle: Text('Dominio: $dom\n${web ?? ''}'),
                  isThreeLine: true,
                  trailing: web == null ? null : const Icon(Icons.open_in_new),
                  onTap: web == null ? null : () => launchUrl(Uri.parse(web), mode: LaunchMode.externalApplication),
                );
              },
            ),
          ),
        ]),
      );
}