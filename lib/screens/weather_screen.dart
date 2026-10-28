// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import '../api.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  static const url = 'https://api.open-meteo.com/v1/forecast?latitude=18.4861&longitude=-69.9312'
      '&current_weather=true&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max'
      '&timezone=America/Santo_Domingo';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Clima en RD')),
        body: FutureBuilder(
          future: getJson(url),
          builder: (_, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return Center(child: Text('${s.error}'));
            final d = s.data;
            final daily = d['daily'];
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Santo Domingo, hoy', style: TextStyle(fontSize: 22)),
                Text('${d['current_weather']['temperature']} °C', style: const TextStyle(fontSize: 56)),
                Text('Máxima: ${daily['temperature_2m_max'][0]} °C'),
                Text('Mínima: ${daily['temperature_2m_min'][0]} °C'),
                Text('Prob. de lluvia: ${daily['precipitation_probability_max'][0]} %'),
              ]),
            );
          },
        ),
      );
}