# Caja de Herramientas

Aplicación multiplataforma desarrollada en **Flutter** que reúne utilidades web en un solo lugar, con una interfaz moderna, responsive y enfocada en la experiencia de usuario.

## Características

- **Inicio:** panel con acceso a todas las herramientas, diseño responsive y navegación animada.
- **Universidades:** búsqueda de instituciones por país mediante selector desplegable (8 países).
- **Clima RD:** clima actual, pronóstico de 7 días, humedad, viento, amanecer y atardecer para 6 ciudades dominicanas.
- **Pokémon:** Pokédex con 12 Pokémon, tipos, estadísticas, habilidades, medidas y reproducción del grito.
- **Noticias:** actualidad dominicana en español desde 5 fuentes (El Día, Proceso, Z101, El Jaya y Robert Cavada).
- **Acerca de:** información del desarrollador, contacto y enlaces a GitHub y LinkedIn.

## Tecnologías

- Flutter 3.x / Dart 3.x
- Material 3
- `http` para consumo de APIs
- `url_launcher` para enlaces externos
- `audioplayers` para los gritos de Pokémon

## APIs utilizadas

| Herramienta | API |
| --- | --- |
| Universidades | `https://adamix.net/proxy.php` |
| Clima | `https://api.open-meteo.com/v1/forecast` |
| Pokémon | `https://pokeapi.co/api/v2/pokemon` |
| Noticias | WordPress REST API de medios dominicanos |

## Ejecutar el proyecto

```bash
flutter pub get
flutter run -d chrome
```

También puedes ejecutarlo en escritorio o móvil:

```bash
flutter run -d windows
flutter run
```

## Compilar para producción

```bash
# Web
flutter build web --release

# Android
flutter build apk --release
```

## Estructura

```text
lib/
├── main.dart                  # Pantalla principal y navegación
├── theme.dart                 # Paleta, gradientes y tema global
├── api.dart                   # Helper para peticiones JSON
└── screens/
    ├── about_screen.dart
    ├── gender_screen.dart
    ├── pokemon_screen.dart
    ├── universities_screen.dart
    ├── user_screen.dart
    ├── weather_screen.dart
    └── wordpress_screen.dart
```

## Autor

**Angel Jefferson Sánchez Ventura**  
Estudiante de Desarrollo de Software · ITLA

- GitHub: [AngelJefferson](https://github.com/AngelJefferson)
- LinkedIn: [angeljsanchez-v](https://www.linkedin.com/in/angeljsanchez-v)
