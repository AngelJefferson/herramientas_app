// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../theme.dart';

class WordpressScreen extends StatefulWidget {
  const WordpressScreen({super.key});

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _NewsSource {
  const _NewsSource(this.name, this.baseUrl, this.label, this.color);

  final String name;
  final String baseUrl;
  final String label;
  final Color color;
}

class _WordpressScreenState extends State<WordpressScreen> {
  static const _sources = <_NewsSource>[
    _NewsSource('El Día', 'https://eldia.com.do', 'General', AppColors.emerald),
    _NewsSource(
      'Proceso',
      'https://proceso.com.do',
      'Política',
      AppColors.violet,
    ),
    _NewsSource(
      'Z101',
      'https://z101digital.com',
      'Entretenimiento',
      AppColors.rose,
    ),
    _NewsSource('El Jaya', 'https://eljaya.com', 'Regionales', AppColors.blue),
    _NewsSource(
      'Robert Cavada',
      'https://robertocavada.com',
      'Opinión',
      AppColors.amber,
    ),
  ];

  _NewsSource _source = _sources.first;
  late Future<List<dynamic>> _future = _cargar();

  Future<List<dynamic>> _cargar() async {
    final data = await getJson(
      '${_source.baseUrl}/wp-json/wp/v2/posts?per_page=10&_embed=1',
    );
    return data is List ? data : <dynamic>[];
  }

  Future<void> _refresh() async {
    setState(() => _future = _cargar());
    try {
      await _future;
    } catch (_) {
      // El FutureBuilder muestra el estado de error.
    }
  }

  void _changeSource(_NewsSource source) {
    setState(() {
      _source = source;
      _future = _cargar();
    });
  }

  Future<void> _open(String? link) async {
    if (link == null || link.isEmpty) return;
    try {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Si el navegador no está disponible, no hacemos nada.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppGradients.news,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            tooltip: 'Volver',
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOTICIAS',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'República Dominicana',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _refresh,
                            tooltip: 'Actualizar',
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          'La actualidad dominicana, en español y al instante.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _sourceSelector(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _LoadingState();
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(onRetry: _refresh);
                  }
                  final posts = snapshot.data ?? const <dynamic>[];
                  if (posts.isEmpty) {
                    return _EmptyState(onRetry: _refresh);
                  }
                  return _newsList(posts);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_NewsSource>(
          value: _source,
          isExpanded: true,
          dropdownColor: AppColors.navy,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (context) => [
            for (final source in _sources)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: source.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Fuente: ${source.name}'),
                ],
              ),
          ],
          items: [
            for (final source in _sources)
              DropdownMenuItem(
                value: source,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: source.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(source.name),
                    const Spacer(),
                    Text(
                      source.label,
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
          onChanged: (source) {
            if (source != null && source != _source) _changeSource(source);
          },
        ),
      ),
    );
  }

  Widget _newsList(List<dynamic> posts) {
    final featured = _post(posts.first);
    final rest = posts.skip(1).toList();
    return RefreshIndicator(
      onRefresh: _refresh,
      color: _source.color,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lo más reciente',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
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
                  '${posts.length} artículos',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FeaturedCard(
            post: featured,
            accent: _source.color,
            onTap: () => _open(_link(featured)),
          ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Más noticias',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in rest)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NewsCard(
                  post: _post(item),
                  accent: _source.color,
                  onTap: () => _open(_link(_post(item))),
                ),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            'Fuente: ${_source.name} · Noticias en español',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.8),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.post,
    required this.accent,
    required this.onTap,
  });

  final Map<String, dynamic> post;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = _image(post);
    final title = _rendered(post['title']);
    final excerpt = _rendered(post['excerpt']);
    final category = _category(post);
    final date = _dateLabel('${post['date'] ?? ''}');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              height: 210,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null)
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _imageFallback(accent),
                    )
                  else
                    _imageFallback(accent),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.ink.withValues(alpha: 0.90),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            height: 1.24,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      excerpt.isEmpty
                          ? 'Toca para leer la noticia completa.'
                          : _truncate(excerpt, 155),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.3,
                        color: AppColors.muted,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.post,
    required this.accent,
    required this.onTap,
  });

  final Map<String, dynamic> post;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = _image(post);
    final title = _rendered(post['title']);
    final category = _category(post);
    final date = _dateLabel('${post['date'] ?? ''}');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: image == null
                      ? Icon(
                          Icons.newspaper_rounded,
                          size: 30,
                          color: accent.withValues(alpha: 0.55),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.newspaper_rounded,
                            size: 30,
                            color: accent.withValues(alpha: 0.55),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando noticias...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted.withValues(alpha: 0.9),
            ),
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
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No pudimos cargar las noticias',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Revisa tu conexión a internet e intenta nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.newspaper_rounded, size: 54, color: AppColors.muted),
          const SizedBox(height: 14),
          const Text(
            'No hay noticias disponibles',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

Widget _imageFallback(Color accent) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [accent.withValues(alpha: 0.75), AppColors.ink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(Icons.newspaper_rounded, size: 56, color: Colors.white24),
    ),
  );
}

Map<String, dynamic> _post(dynamic value) {
  if (value is Map) return value.cast<String, dynamic>();
  return const <String, dynamic>{};
}

String _rendered(dynamic value) {
  if (value is Map && value['rendered'] != null) {
    return _clean('${value['rendered']}');
  }
  return '';
}

String _link(Map<String, dynamic> post) {
  final link = post['link'];
  return link is String ? link : '';
}

String? _image(Map<String, dynamic> post) {
  final embedded = post['_embedded'];
  if (embedded is Map) {
    final media = embedded['wp:featuredmedia'];
    if (media is List && media.isNotEmpty) {
      final first = media.first;
      if (first is Map && first['source_url'] is String) {
        final url = first['source_url'] as String;
        if (url.isNotEmpty) return _imageUrl(url);
      }
    }
  }
  return null;
}

/// En web, algunas imágenes de los diarios no envían cabeceras CORS.
/// Las servimos mediante un proxy de imágenes para que puedan mostrarse.
String _imageUrl(String url) {
  if (!kIsWeb) return url;
  return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&w=900&q=80';
}

String _category(Map<String, dynamic> post) {
  final embedded = post['_embedded'];
  if (embedded is Map) {
    final terms = embedded['wp:term'];
    if (terms is List) {
      for (final group in terms) {
        if (group is List) {
          for (final term in group) {
            if (term is Map &&
                term['taxonomy'] == 'category' &&
                term['name'] is String) {
              return (term['name'] as String).toUpperCase();
            }
          }
        }
      }
    }
  }
  return 'ACTUALIDAD';
}

String _clean(String html) {
  var text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&quot;': '"',
    '&#039;': "'",
    '&#39;': "'",
    '&lt;': '<',
    '&gt;': '>',
    '&hellip;': '…',
    '&mdash;': '—',
    '&ndash;': '–',
    '&#8211;': '–',
    '&#8212;': '—',
    '&#8216;': '‘',
    '&#8217;': '’',
    '&#8220;': '“',
    '&#8221;': '”',
    '&#8230;': '…',
  };
  entities.forEach((key, value) => text = text.replaceAll(key, value));
  text = text.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) => String.fromCharCode(int.tryParse(match[1] ?? '') ?? 32),
  );
  text = text.replaceAllMapped(
    RegExp(r'&#x([0-9a-fA-F]+);'),
    (match) =>
        String.fromCharCode(int.tryParse(match[1] ?? '', radix: 16) ?? 32),
  );
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _truncate(String value, int max) {
  if (value.length <= max) return value;
  return '${value.substring(0, max).trimRight()}…';
}

String _dateLabel(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final suffix = date.hour < 12 ? 'a. m.' : 'p. m.';
  final minutes = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} · $hour:$minutes $suffix';
}
