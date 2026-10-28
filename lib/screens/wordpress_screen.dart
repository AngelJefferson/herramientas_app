// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';

class WordpressScreen extends StatelessWidget {
  const WordpressScreen({super.key});

  static const site = 'https://techcrunch.com';
  static const logo = 'https://techcrunch.com/wp-content/uploads/2015/02/cropped-cropped-favicon-gradient.png?w=64'; // cámbialo por el logo de tu sitio

  String limpiar(String h) => h.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&#8217;', "'").replaceAll('&#8211;', '-').trim();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Últimas noticias')),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: Image.network(logo, height: 70)),
          Expanded(
            child: FutureBuilder(
              future: getJson('$site/wp-json/wp/v2/posts?per_page=3'),
              builder: (_, s) {
                if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                if (s.hasError) return Center(child: Text('${s.error}'));
                final posts = s.data as List;
                return ListView(children: [
                  for (final p in posts)
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(limpiar(p['title']['rendered']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(limpiar(p['excerpt']['rendered'])),
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse(p['link']), mode: LaunchMode.externalApplication),
                            child: const Text('Visitar')),
                        ]),
                      ),
                    ),
                ]);
              },
            ),
          ),
        ]),
      );
}