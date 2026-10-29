// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../theme.dart';

typedef _WeatherInfo = ({IconData icon, String label, List<Color> colors});

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _City {
  const _City(this.name, this.province, this.latitude, this.longitude);

  final String name;
  final String province;
  final double latitude;
  final double longitude;
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const _cities = <_City>[
    _City('Santo Domingo', 'Distrito Nacional', 18.4861, -69.9312),
    _City('Santiago', 'Santiago', 19.4517, -70.6970),
    _City('Punta Cana', 'La Altagracia', 18.5601, -68.3725),
    _City('Puerto Plata', 'Puerto Plata', 19.7934, -70.6884),
    _City('La Romana', 'La Romana', 18.4273, -68.9728),
    _City('Samaná', 'Samaná', 19.2056, -69.3364),
  ];

  _City _city = _cities.first;
  late Future<Map<String, dynamic>> _future = _fetch();

  Future<Map<String, dynamic>> _fetch() async {
    final url =
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${_city.latitude}&longitude=${_city.longitude}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
        'is_day,precipitation,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
        'precipitation_probability_max,sunrise,sunset'
        '&timezone=America%2FSanto_Domingo&forecast_days=7';
    final data = await getJson(url);
    return (data as Map).cast<String, dynamic>();
  }

  void _changeCity(_City city) {
    setState(() {
      _city = city;
      _future = _fetch();
    });
  }

  Future<void> _refresh() async {
    setState(() => _future = _fetch());
    try {
      await _future;
    } catch (_) {
      // El FutureBuilder muestra el estado de error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final current = data == null ? null : _map(data['current']);
            final code = _int(current?['weather_code']);
            final isDay = _int(current?['is_day']) == 1;
            final info =
                snapshot.connectionState == ConnectionState.done && data != null
                ? _weatherFor(code, isDay)
                : _weatherFor(0, true);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 550),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: info.colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _topBar(context),
                    Expanded(child: _body(snapshot, info)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clima en RD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Pronóstico en tiempo real',
                  style: TextStyle(color: Colors.white60, fontSize: 10.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refresh,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _body(
    AsyncSnapshot<Map<String, dynamic>> snapshot,
    _WeatherInfo info,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (snapshot.hasError || snapshot.data == null) {
      return _ErrorState(onRetry: _refresh);
    }

    final data = snapshot.data!;
    final current = _map(data['current']);
    final daily = _map(data['daily']);
    final times = _list(daily['time']);
    final highs = _list(daily['temperature_2m_max']);
    final lows = _list(daily['temperature_2m_min']);
    final rain = _list(daily['precipitation_probability_max']);
    final codes = _list(daily['weather_code']);
    final sunrises = _list(daily['sunrise']);
    final sunsets = _list(daily['sunset']);

    final temperature = _double(current['temperature_2m']);
    final feelsLike = _double(current['apparent_temperature']);
    final humidity = _int(current['relative_humidity_2m']);
    final wind = _double(current['wind_speed_10m']);
    final precipitation = _double(current['precipitation']);
    final todayRain = rain.isEmpty ? 0 : _int(rain.first);
    final todayHigh = highs.isEmpty ? 0.0 : _double(highs.first);
    final todayLow = lows.isEmpty ? 0.0 : _double(lows.first);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.navy,
      backgroundColor: Colors.white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          _citySelector(),
          const SizedBox(height: 24),
          Text(
            _city.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${_city.province} · ${_longDate(times.isEmpty ? '' : '${times.first}')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            info.icon,
            size: 90,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text(
              '${temperature.round()}°',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w200,
                height: 1,
                letterSpacing: -4,
              ),
            ),
          ),
          Text(
            info.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sensación ${feelsLike.round()}°  ·  Máx ${todayHigh.round()}°  /  Mín ${todayLow.round()}°',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.water_drop_rounded,
                  label: 'Humedad',
                  value: '$humidity%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.air_rounded,
                  label: 'Viento',
                  value: '${wind.round()} km/h',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.umbrella_rounded,
                  label: 'Lluvia',
                  value: '$todayRain%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Próximos 7 días',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Máx / Mín',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (
                  int i = 0;
                  i < times.length &&
                      i < 7 &&
                      i < highs.length &&
                      i < lows.length;
                  i++
                )
                  _ForecastRow(
                    label: i == 0 ? 'Hoy' : _shortDay('${times[i]}'),
                    code: i < codes.length ? _int(codes[i]) : 0,
                    max: _double(highs[i]),
                    min: _double(lows[i]),
                    rain: i < rain.length ? _int(rain[i]) : 0,
                    isToday: i == 0,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SunTile(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Amanecer',
                  value: _hour(sunrises.isEmpty ? '' : '${sunrises.first}'),
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SunTile(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Atardecer',
                  value: _hour(sunsets.isEmpty ? '' : '${sunsets.first}'),
                  color: AppColors.rose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            precipitation > 0
                ? 'Precipitación actual: ${precipitation.toStringAsFixed(1)} mm'
                : 'Actualizado con datos de Open-Meteo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _citySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_City>(
          value: _city,
          isExpanded: true,
          dropdownColor: const Color(0xFF13233F),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (context) => [
            for (final city in _cities)
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 8),
                  Text(city.name),
                ],
              ),
          ],
          items: [
            for (final city in _cities)
              DropdownMenuItem(
                value: city,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 17,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 8),
                    Text(city.name),
                    const Spacer(),
                    Text(
                      city.province,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (city) {
            if (city != null && city != _city) _changeCity(city);
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: Colors.white.withValues(alpha: 0.72)),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.50),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.label,
    required this.code,
    required this.max,
    required this.min,
    required this.rain,
    required this.isToday,
  });

  final String label;
  final int code;
  final double max;
  final double min;
  final int rain;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final info = _weatherFor(code, true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Icon(
            info.icon,
            size: 18,
            color: Colors.white.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.water_drop_rounded,
            size: 11,
            color: AppColors.cyan.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 3),
          SizedBox(
            width: 30,
            child: Text(
              '$rain%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 10,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${max.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${min.round()}°',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SunTile extends StatelessWidget {
  const _SunTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 46,
                color: Colors.white,
              ),
              const SizedBox(height: 14),
              const Text(
                'No pudimos obtener el clima',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Revisa tu conexión a internet e intenta nuevamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return value.cast<String, dynamic>();
  return const <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _int(dynamic value) => value is num ? value.toInt() : 0;

double _double(dynamic value) => value is num ? value.toDouble() : 0;

const _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const _shortWeekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String _longDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
}

String _shortDay(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return _shortWeekdays[date.weekday - 1];
}

String _hour(String iso) {
  if (iso.length < 16) return '--:--';
  return iso.substring(11, 16);
}

_WeatherInfo _weatherFor(int code, bool isDay) {
  if (code == 0) {
    return isDay
        ? (
            icon: Icons.wb_sunny_rounded,
            label: 'Despejado',
            colors: const [
              Color(0xFF0EA5E9),
              Color(0xFF0369A1),
              Color(0xFF0C4A6E),
            ],
          )
        : (
            icon: Icons.nightlight_round,
            label: 'Cielo despejado',
            colors: const [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF312E81),
            ],
          );
  }
  if (code == 1 || code == 2) {
    return (
      icon: Icons.wb_sunny_rounded,
      label: code == 1 ? 'Mayormente despejado' : 'Parcialmente nublado',
      colors: const [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF075985)],
    );
  }
  if (code == 3) {
    return (
      icon: Icons.cloud_rounded,
      label: 'Nublado',
      colors: const [Color(0xFF64748B), Color(0xFF475569), Color(0xFF1E293B)],
    );
  }
  if (code == 45 || code == 48) {
    return (
      icon: Icons.foggy,
      label: 'Niebla',
      colors: const [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF334155)],
    );
  }
  if (code >= 51 && code <= 57) {
    return (
      icon: Icons.grain_rounded,
      label: 'Llovizna',
      colors: const [Color(0xFF0E7490), Color(0xFF155E75), Color(0xFF164E63)],
    );
  }
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return (
      icon: Icons.water_drop_rounded,
      label: 'Lluvia',
      colors: const [Color(0xFF0891B2), Color(0xFF0E7490), Color(0xFF164E63)],
    );
  }
  if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
    return (
      icon: Icons.ac_unit_rounded,
      label: 'Nieve',
      colors: const [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF075985)],
    );
  }
  if (code >= 95 && code <= 99) {
    return (
      icon: Icons.thunderstorm_rounded,
      label: 'Tormenta eléctrica',
      colors: const [Color(0xFF312E81), Color(0xFF1E1B4B), Color(0xFF0F172A)],
    );
  }
  return isDay
      ? (
          icon: Icons.filter_drama_rounded,
          label: 'Clima variable',
          colors: const [
            Color(0xFF0EA5E9),
            Color(0xFF0369A1),
            Color(0xFF0C4A6E),
          ],
        )
      : (
          icon: Icons.dark_mode_rounded,
          label: 'Clima variable',
          colors: const [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF312E81),
          ],
        );
}
