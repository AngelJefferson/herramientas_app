// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../theme.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  static const _pokemons = <(String, String)>[
    ('bulbasaur', 'Bulbasaur'),
    ('charmander', 'Charmander'),
    ('squirtle', 'Squirtle'),
    ('pikachu', 'Pikachu'),
    ('eevee', 'Eevee'),
    ('gengar', 'Gengar'),
    ('snorlax', 'Snorlax'),
    ('dragonite', 'Dragonite'),
    ('lucario', 'Lucario'),
    ('greninja', 'Greninja'),
    ('mewtwo', 'Mewtwo'),
    ('garchomp', 'Garchomp'),
  ];

  static const _statKeys = <(String, String)>[
    ('hp', 'PS'),
    ('attack', 'Ataque'),
    ('defense', 'Defensa'),
    ('special-attack', 'At. Esp.'),
    ('special-defense', 'Def. Esp.'),
    ('speed', 'Velocidad'),
  ];

  static const _typeNames = {
    'grass': 'Planta',
    'fire': 'Fuego',
    'water': 'Agua',
    'electric': 'Eléctrico',
    'poison': 'Veneno',
    'normal': 'Normal',
    'flying': 'Volador',
    'bug': 'Bicho',
    'ghost': 'Fantasma',
    'steel': 'Acero',
    'psychic': 'Psíquico',
    'ice': 'Hielo',
    'dragon': 'Dragón',
    'dark': 'Siniestro',
    'fairy': 'Hada',
    'fighting': 'Lucha',
    'ground': 'Tierra',
    'rock': 'Roca',
  };

  static const _typeColors = {
    'grass': Color(0xFF22C55E),
    'fire': Color(0xFFF97316),
    'water': Color(0xFF3B82F6),
    'electric': Color(0xFFFACC15),
    'poison': Color(0xFFA855F7),
    'normal': Color(0xFF94A3B8),
    'flying': Color(0xFF38BDF8),
    'bug': Color(0xFF84CC16),
    'ghost': Color(0xFF8B5CF6),
    'steel': Color(0xFF64748B),
    'psychic': Color(0xFFEC4899),
    'ice': Color(0xFF67E8F9),
    'dragon': Color(0xFF6366F1),
    'dark': Color(0xFF334155),
    'fairy': Color(0xFFF9A8D4),
    'fighting': Color(0xFFEF4444),
    'ground': Color(0xFFD97706),
    'rock': Color(0xFFA16207),
  };

  final _player = AudioPlayer();

  String _selected = 'pikachu';
  Map<String, dynamic>? _pokemon;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _buscar(_selected);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _buscar(String name) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await getJson('https://pokeapi.co/api/v2/pokemon/$name');
      if (!mounted) return;
      setState(() {
        _pokemon = (data as Map).cast<String, dynamic>();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pokemon = null;
        _error = 'No pudimos cargar este Pokémon. Intenta nuevamente.';
        _loading = false;
      });
    }
  }

  Future<void> _playCry() async {
    final cries = _pokemon?['cries'];
    final url = cries is Map ? cries['latest'] : null;
    if (url is! String || url.isEmpty) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (_) {
      // Silencioso: el grito es opcional.
    }
  }

  List<String> _types(Map<String, dynamic>? pokemon) {
    final types = pokemon?['types'];
    if (types is! List) return const [];
    return [
      for (final item in types)
        if (item is Map && item['type'] is Map) '${item['type']['name']}',
    ];
  }

  int _stat(String key) {
    final stats = _pokemon?['stats'];
    if (stats is! List) return 0;
    for (final item in stats) {
      if (item is Map && item['stat'] is Map && item['stat']['name'] == key) {
        final value = item['base_stat'];
        if (value is num) return value.toInt();
      }
    }
    return 0;
  }

  List<String> _abilities() {
    final abilities = _pokemon?['abilities'];
    if (abilities is! List) return const [];
    return [
      for (final item in abilities)
        if (item is Map && item['ability'] is Map)
          _pretty('${item['ability']['name']}'),
    ];
  }

  String? _artwork() {
    final sprites = _pokemon?['sprites'];
    if (sprites is Map) {
      final other = sprites['other'];
      if (other is Map) {
        final artwork = other['official-artwork'];
        if (artwork is Map && artwork['front_default'] is String) {
          return artwork['front_default'] as String;
        }
      }
      if (sprites['front_default'] is String) {
        return sprites['front_default'] as String;
      }
    }
    return null;
  }

  Color get _accent {
    final types = _types(_pokemon);
    if (types.isEmpty) return AppColors.amber;
    return _typeColors[types.first] ?? AppColors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final hasPokemon = _pokemon != null;
    final background = hasPokemon
        ? [
            Color.lerp(accent, Colors.black, 0.50)!,
            Color.lerp(accent, Colors.black, 0.74)!,
            AppColors.ink,
          ]
        : const [AppColors.ink, Color(0xFF16213E), Color(0xFF0B1220)];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 550),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: background,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _topBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                  child: _selector(),
                ),
                Expanded(child: _content(accent)),
              ],
            ),
          ),
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
                  'Pokédex',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Explora y escucha a tus favoritos',
                  style: TextStyle(color: Colors.white60, fontSize: 10.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : () => _buscar(_selected),
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _selector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selected,
          isExpanded: true,
          menuMaxHeight: 340,
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
          items: [
            for (final pokemon in _pokemons)
              DropdownMenuItem(
                value: pokemon.$1,
                child: Row(
                  children: [
                    const Icon(
                      Icons.catching_pokemon_rounded,
                      size: 17,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 9),
                    Text(pokemon.$2),
                    const Spacer(),
                    Text(
                      '#${(1 + _pokemons.indexOf(pokemon)).toString().padLeft(3, '0')}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (value) {
            if (value == null || value == _selected) return;
            setState(() => _selected = value);
            _buscar(value);
          },
        ),
      ),
    );
  }

  Widget _content(Color accent) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: () => _buscar(_selected));
    }
    final pokemon = _pokemon;
    if (pokemon == null) {
      return const Center(
        child: Text(
          'Selecciona un Pokémon',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final id = pokemon['id'] is num ? (pokemon['id'] as num).toInt() : 0;
    final height = pokemon['height'] is num
        ? (pokemon['height'] as num).toDouble() / 10
        : 0.0;
    final weight = pokemon['weight'] is num
        ? (pokemon['weight'] as num).toDouble() / 10
        : 0.0;
    final experience = pokemon['base_experience'] is num
        ? (pokemon['base_experience'] as num).toInt()
        : 0;
    final types = _types(pokemon);
    final abilities = _abilities();
    final image = _artwork();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 42,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: image == null
                ? const Icon(
                    Icons.catching_pokemon_rounded,
                    size: 100,
                    color: Colors.white54,
                  )
                : Image.network(
                    image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.catching_pokemon_rounded,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '#${id.toString().padLeft(4, '0')}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.50),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _pretty('${pokemon['name']}'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in types)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _typeColors[type] ?? Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _typeNames[type] ?? _pretty(type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _InfoPill(
                icon: Icons.height_rounded,
                label: 'Altura',
                value: '${height.toStringAsFixed(1)} m',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoPill(
                icon: Icons.monitor_weight_rounded,
                label: 'Peso',
                value: '${weight.toStringAsFixed(1)} kg',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoPill(
                icon: Icons.bolt_rounded,
                label: 'Exp. base',
                value: '$experience',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Estadísticas base',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.insights_rounded,
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.50),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final stat in _statKeys) ...[
                _StatBar(label: stat.$2, value: _stat(stat.$1), color: accent),
                if (stat != _statKeys.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        if (abilities.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'HABILIDADES',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ability in abilities)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    ability,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _playCry,
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            label: const Text('Escuchar grito'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
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
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: Colors.white.withValues(alpha: 0.70)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / 180).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 10.5,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
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
                Icons.catching_pokemon_rounded,
                size: 46,
                color: Colors.white,
              ),
              const SizedBox(height: 14),
              const Text(
                'Pokémon no encontrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
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

String _pretty(String value) {
  return value
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
