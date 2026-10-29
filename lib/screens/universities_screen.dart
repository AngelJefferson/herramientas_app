// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../theme.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _Country {
  const _Country(this.apiName, this.label, this.flag);

  final String apiName;
  final String label;
  final String flag;
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  static const _countries = <_Country>[
    _Country('Dominican Republic', 'República Dominicana', '🇩🇴'),
    _Country('United States', 'Estados Unidos', '🇺🇸'),
    _Country('Spain', 'España', '🇪🇸'),
    _Country('Mexico', 'México', '🇲🇽'),
    _Country('Colombia', 'Colombia', '🇨🇴'),
    _Country('Argentina', 'Argentina', '🇦🇷'),
    _Country('Chile', 'Chile', '🇨🇱'),
    _Country('Peru', 'Perú', '🇵🇪'),
  ];

  String _selected = 'Dominican Republic';
  List<dynamic> _data = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await getJson(
        'https://adamix.net/proxy.php?country=${Uri.encodeQueryComponent(_selected)}',
      );
      if (!mounted) return;
      setState(() {
        _data = d is List ? d : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las universidades.\n$e';
        _loading = false;
      });
    }
  }

  _Country get _currentCountry =>
      _countries.firstWhere((c) => c.apiName == _selected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppGradients.header,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: AppColors.teal,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Encuentra tu universidad',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Explora instituciones de 8 países',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _selected,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: const InputDecoration(
                      labelText: 'País',
                      prefixIcon: Icon(Icons.public_rounded),
                      fillColor: Colors.white,
                    ),
                    items: [
                      for (final c in _countries)
                        DropdownMenuItem(
                          value: c.apiName,
                          child: Text('${c.flag}  ${c.label}'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null || value == _selected) return;
                      setState(() => _selected = value);
                      _buscar();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _buscar,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        _loading ? 'Buscando...' : 'Buscar universidades',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.teal.withValues(
                          alpha: 0.65,
                        ),
                        disabledForegroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading && _data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Algo salió mal',
        message: _error!,
        actionLabel: 'Intentar de nuevo',
        onAction: _buscar,
      );
    }
    if (_data.isEmpty) {
      return _MessageState(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados',
        message:
            'No encontramos universidades para ${_currentCountry.label}. Prueba con otro país.',
        actionLabel: 'Actualizar',
        onAction: _buscar,
      );
    }

    return RefreshIndicator(
      onRefresh: _buscar,
      color: AppColors.teal,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              Text(
                '${_data.length} universidades',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${_currentCountry.flag} ${_currentCountry.label}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in _data)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UniversityCard(university: item),
            ),
        ],
      ),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.university});

  final dynamic university;

  String? get _website {
    final pages = university is Map ? university['web_pages'] : null;
    if (pages is List && pages.isNotEmpty) return pages.first?.toString();
    return null;
  }

  String get _domain {
    final domains = university is Map ? university['domains'] : null;
    if (domains is List && domains.isNotEmpty) return domains.first.toString();
    return 'Sin dominio';
  }

  String get _name => university is Map
      ? '${university['name'] ?? 'Universidad'}'
      : 'Universidad';

  Future<void> _open() async {
    final url = _website;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final website = _website;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: website == null ? null : _open,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.violet,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 13,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (website != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Visitar sitio web',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (website != null)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    size: 17,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 34, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
