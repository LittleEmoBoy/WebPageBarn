import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

// =============================================================
// CONTENIDO EDITABLE: cambia aquí los textos, enlaces y datos
// =============================================================
class Content {
  static const studio = 'Barn Studio';
  static const headline = 'Forging worlds, breaking rules.';
  static const tagline =
      'We are Barn Studio. We are creating The Owl Path, an exploration and mystery metroidvania where every mask hides a truth.';

  static const gameTitle = 'The Owl Path';
  static const gameText =
      'An exploration metroidvania with a dark story. Travel through a gloomy world in search of your missing companion and uncover, mask by mask, the strange truth behind their disappearance.';

  static const tags = ['Metroidvania', 'Exploration', 'Dark story', 'Mystery'];

  // (icono, título, texto)
  static const pillars = [
    (Icons.explore_outlined, 'Exploration',
        'An interconnected world that opens up with every step forward. Shortcuts, secrets and hidden corners that only reward those who stop to look.'),
    (Icons.theater_comedy_outlined, 'Masks',
        'Every mask you find changes the way you play and reveals a fragment of an uncomfortable truth.'),
    (Icons.person_search_outlined, 'A Lost Companion',
        'Your companion has vanished. Following their trail will lead you to places that grow darker and darker.'),
  ];

  // ID del vídeo de YouTube: youtube.com/watch?v=ESTE_ID (vacío = "próximamente")
  static const trailerId = '';
  static const demoUrl = ''; // enlace a la demo (itch.io...). Vacío = botón oculto

  // Enlaces a documentos (Drive, PDF publicado...). Vacío = "Próximamente"
  static const gddUrl = '';
  static const budgetUrl = '';
  static const chartsUrl = '';

  static const email = 'your-email@example.com';
  static const formEndpoint = ''; // opcional: URL de Formspree para enviar sin abrir el correo

  // Capturas: guarda las imágenes en assets/gallery/ con estos nombres
  static const gallery = [
    'assets/gallery/1.png', 'assets/gallery/2.png', 'assets/gallery/3.png',
    'assets/gallery/4.png', 'assets/gallery/5.png', 'assets/gallery/6.png',
  ];

  // Datos de ejemplo: sustitúyelos por los de tu presupuesto (en %)
  static const budget = [
    ('Staff', 45), ('Art', 20), ('Marketing', 15), ('Audio', 10), ('Tools', 10),
  ];

  // (nombre, rol, bio)
  static const team = [
    ('Raúl', 'Programming and game design', 'Builds the exploration mechanics and shapes the playable experience of The Owl Path.'),
    ('Artist', 'Art direction', 'Defines the visual style of a gloomy world and of every mask in the game.'),
    ('Producer', 'Project management', 'Coordinates the team, the deadlines and the studio communication.'),
  ];

  // (fecha, título, descripción, ya realizado)
  static const events = [
    ('October 2026', 'Demo release', 'Launch on Itch.io and Steam Next Fest.', true),
    ('November 2026', 'Indie Dev Day', 'In-person showcase at the student booth.', false),
    ('December 2026', 'Final project delivery', 'Presentation of the complete game and the GDD.', false),
  ];

  static const socials = [
    (Icons.discord, 'Discord', 'https://discord.com'),
    (Icons.alternate_email, 'X', 'https://x.com'),
    (Icons.camera_alt_outlined, 'Instagram', 'https://instagram.com'),
    (Icons.videogame_asset_outlined, 'itch.io', 'https://itch.io'),
    (Icons.smart_display_outlined, 'YouTube', 'https://youtube.com'),
  ];
}

// Paleta Edgerunners: noche violeta con amarillo ácido, rosa fucsia y cian
class C {
  static const deep = Color(0xFF05030C),
      ink = Color(0xFF0A0614),
      night = Color(0xFF120A26),
      card = Color(0xFF1A1033),
      line = Color(0xFF3A2A6A),
      text = Color(0xFFF4F1FF),
      muted = Color(0xFFA99FD0),
      yellow = Color(0xFFFCEE09),
      cyan = Color(0xFF00E5FF),
      pink = Color(0xFFFF2A8A),
      red = Color(0xFFFF2638),
      violet = Color(0xFFB26BFF);
  static const List<Color> neon = [yellow, pink, cyan];
}

List<Shadow>? _glow(Color? g) => g == null
    ? null
    : [Shadow(color: g.withValues(alpha: .6), blurRadius: 16), Shadow(color: g.withValues(alpha: .3), blurRadius: 36)];

TextStyle _h(double s, [Color c = C.text, Color? glow, bool italic = false]) => GoogleFonts.chakraPetch(
    fontSize: s,
    fontWeight: FontWeight.w700,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    height: 1.1,
    color: c,
    shadows: _glow(glow));

// Fuente propia (Barnowl): solo tiene letras A-Z, ? y !. Sin tildes, ñ, números ni puntuación.
TextStyle _rune(double s, [Color c = C.text, Color? glow]) => TextStyle(
    fontFamily: 'Barnowl', fontWeight: FontWeight.w400, fontSize: s, color: c, letterSpacing: 1.5, height: 1.1,
    shadows: _glow(glow));

Widget _p(String t, {double s = 17, Color c = C.muted, TextAlign? a}) =>
    Text(t, textAlign: a, style: TextStyle(fontSize: s, height: 1.55, color: c));

// Pasa el tema de google_fonts a un TextTheme de Flutter (evita choques de tipos entre versiones)
TextTheme _bodyTheme() {
  final t = GoogleFonts.chakraPetchTextTheme();
  return TextTheme(
    displayLarge: t.displayLarge, displayMedium: t.displayMedium, displaySmall: t.displaySmall,
    headlineLarge: t.headlineLarge, headlineMedium: t.headlineMedium, headlineSmall: t.headlineSmall,
    titleLarge: t.titleLarge, titleMedium: t.titleMedium, titleSmall: t.titleSmall,
    bodyLarge: t.bodyLarge, bodyMedium: t.bodyMedium, bodySmall: t.bodySmall,
    labelLarge: t.labelLarge, labelMedium: t.labelMedium, labelSmall: t.labelSmall,
  ).apply(bodyColor: C.text, displayColor: C.text);
}

Duration _d(BuildContext c, [int ms = 200]) =>
    MediaQuery.disableAnimationsOf(c) ? Duration.zero : Duration(milliseconds: ms);

Future<void> _open(String u) => launchUrl(Uri.parse(u), webOnlyWindowName: '_blank');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Descarga las tipografías antes del primer fotograma, mientras se ve la pantalla de carga
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.chakraPetch(fontWeight: FontWeight.w700),
      GoogleFonts.chakraPetch(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
      GoogleFonts.chakraPetch(),
      GoogleFonts.chakraPetch(fontWeight: FontWeight.w500),
    ]).timeout(const Duration(seconds: 4));
  } catch (_) {}
  runApp(const BarnStudioApp());
}

class BarnStudioApp extends StatelessWidget {
  const BarnStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barn Studio | Indie Games',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: C.ink,
        colorScheme: ColorScheme.fromSeed(seedColor: C.cyan, brightness: Brightness.dark, surface: C.ink),
        textTheme: _bodyTheme(),
        popupMenuTheme: PopupMenuThemeData(color: C.card, textStyle: const TextStyle(color: C.text, fontSize: 16)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: C.card,
          labelStyle: const TextStyle(color: C.muted),
          border: ob(C.line),
          enabledBorder: ob(C.line),
          focusedBorder: ob(C.cyan, 2),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ---------------------------------------------------------------- Interacción reutilizable
/// Envuelve cualquier widget: detecta ratón y teclado, y lo eleva ligeramente al pasar por encima.
class _Hover extends StatefulWidget {
  final Widget Function(bool hovered) builder;
  final VoidCallback? onTap;
  final double lift;
  const _Hover({required this.builder, this.onTap, this.lift = 4});
  @override
  State<_Hover> createState() => _HoverState();
}

class _HoverState extends State<_Hover> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final body = AnimatedContainer(
      duration: _d(context),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _h ? -widget.lift : 0, 0),
      child: widget.builder(_h),
    );
    if (widget.onTap == null) {
      return MouseRegion(
          onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false), child: body);
    }
    return Semantics(
      button: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _h = v),
        onShowFocusHighlight: (v) => setState(() => _h = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap!();
            return null;
          })
        },
        child: GestureDetector(onTap: widget.onTap, child: body),
      ),
    );
  }
}

/// Forma de panel cyberpunk: dos esquinas cortadas en diagonal
BeveledRectangleBorder _bevel(double r, [Color? c, double w = 1]) => BeveledRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(r), bottomRight: Radius.circular(r)),
      side: c == null ? BorderSide.none : BorderSide(color: c, width: w),
    );

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final IconData? icon;
  final Color? color;
  const _Btn(this.label, this.onTap, {this.primary = true, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final off = onTap == null;
    final base = color ?? (primary ? C.yellow : C.cyan);
    return _Hover(
      onTap: onTap,
      lift: off ? 0 : 3,
      builder: (h) {
        final fg = off ? C.muted : (primary || h ? C.ink : base);
        final fill = off
            ? Colors.transparent
            : (primary ? (h ? Color.lerp(base, Colors.white, .3)! : base) : (h ? base : base.withValues(alpha: .06)));
        return AnimatedContainer(
          duration: _d(context),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          decoration: ShapeDecoration(
            color: fill,
            shape: _bevel(12, off ? C.line : base, 1.5),
            shadows: off
                ? []
                : [
                    BoxShadow(color: base.withValues(alpha: h ? .9 : .4), blurRadius: h ? 28 : 14),
                    if (h) BoxShadow(color: base.withValues(alpha: .4), blurRadius: 64, spreadRadius: 2),
                  ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 10)],
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: .6,
                    color: fg,
                    shadows: (!primary && !h && !off) ? [Shadow(color: base.withValues(alpha: .7), blurRadius: 8)] : null)),
          ]),
        );
      },
    );
  }
}

ShapeDecoration _card([bool h = false, Color glow = C.cyan]) => ShapeDecoration(
      color: C.card,
      shape: _bevel(22, h ? glow : C.line, h ? 1.5 : 1),
      shadows: h
          ? [
              BoxShadow(color: glow.withValues(alpha: .55), blurRadius: 22),
              BoxShadow(color: glow.withValues(alpha: .28), blurRadius: 60, offset: const Offset(0, 16)),
            ]
          : [],
    );

class _Card extends StatelessWidget {
  final Widget child;
  final double? width;
  final VoidCallback? onTap;
  final bool lift;
  final Color glow;
  const _Card({required this.child, this.width, this.onTap, this.lift = true, this.glow = C.cyan});

  @override
  Widget build(BuildContext context) => _Hover(
        onTap: onTap,
        lift: lift ? 6 : 0,
        builder: (h) => AnimatedContainer(
            duration: _d(context),
            width: width,
            padding: const EdgeInsets.all(28),
            decoration: _card(h && lift, glow),
            child: child),
      );
}

// ---------------------------------------------------------------- Página
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const labels = ['Home', 'Game', 'Documentation', 'About', 'Calendar', 'Contact'];
  final keys = List.generate(labels.length, (_) => GlobalKey());
  final _scroll = ScrollController();
  final _active = ValueNotifier<int>(0);
  final _progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max > 0 ? (_scroll.offset / max).clamp(0.0, 1.0) : 0;
    var cur = 0;
    for (var i = 0; i < keys.length; i++) {
      final box = keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.attached && box.localToGlobal(Offset.zero).dy <= 72 + 140) cur = i;
    }
    if (max > 0 && _scroll.offset >= max - 4) cur = keys.length - 1;
    if (_active.value != cur) _active.value = cur;
  }

  void go(int i) {
    final c = keys[i].currentContext;
    if (c != null) {
      Scrollable.ensureVisible(c, duration: _d(context, 600), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 860;
    return Scaffold(
      body: Stack(children: [
        Column(children: [
        ListenableBuilder(
          listenable: Listenable.merge([_active, _progress]),
          builder: (_, __) =>
              _Nav(labels: labels, onTap: go, wide: wide, active: _active.value, progress: _progress.value),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(children: [
              _Reveal(
                  controller: _scroll,
                  first: true,
                  child: _Hero(key: keys[0], onTrailer: () => go(1), onTeam: () => go(3))),
              _Reveal(controller: _scroll, child: _GameSection(key: keys[1])),
              _Reveal(controller: _scroll, child: _DocsSection(key: keys[2])),
              _Reveal(controller: _scroll, child: _AboutSection(key: keys[3])),
              _Reveal(controller: _scroll, child: _EventsSection(key: keys[4])),
              _Reveal(controller: _scroll, child: _ContactSection(key: keys[5])),
              _Footer(onTop: () => go(0)),
            ]),
          ),
        ),
      ]),
        Positioned.fill(child: IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: _ScanPainter())))),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Menú fijo con sección activa
class _Nav extends StatelessWidget {
  final List<String> labels;
  final void Function(int) onTap;
  final bool wide;
  final int active;
  final double progress;
  const _Nav(
      {required this.labels, required this.onTap, required this.wide, required this.active, required this.progress});

  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        decoration: const BoxDecoration(color: C.ink, border: Border(bottom: BorderSide(color: C.line))),
        child: Stack(fit: StackFit.expand, children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
            child: Row(children: [
              _Hover(
                onTap: () => onTap(0),
                lift: 0,
                builder: (_) => Row(children: [
                  Image.asset('assets/logo.png', height: 46, semanticLabel: 'Barn Studio, back to top'),
                  const SizedBox(width: 12),
                  Text(Content.studio, style: _rune(30, C.yellow)),
                ]),
              ),
              const Spacer(),
              if (wide)
                ...[for (var i = 1; i < labels.length; i++) _NavLink(labels[i], active == i, () => onTap(i))]
              else
                PopupMenuButton<int>(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu),
                  onSelected: onTap,
                  itemBuilder: (_) => [
                    for (var i = 0; i < labels.length; i++)
                      PopupMenuItem(value: i, child: Text(labels[i], style: TextStyle(color: active == i ? C.pink : C.text))),
                  ],
                ),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                      height: 2,
                      decoration: const BoxDecoration(color: C.pink, boxShadow: [BoxShadow(color: C.pink, blurRadius: 8)]))),
            ),
          ),
        ]),
      );
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => _Hover(
        onTap: onTap,
        lift: 0,
        builder: (h) {
          final on = active || h;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: on ? C.text : C.muted,
                      shadows: on ? [Shadow(color: C.yellow.withValues(alpha: .8), blurRadius: 12)] : null)),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: _d(context),
                height: 2,
                width: on ? 28 : 0,
                decoration: const BoxDecoration(color: C.yellow, boxShadow: [BoxShadow(color: C.yellow, blurRadius: 8)]),
              ),
            ]),
          );
        },
      );
}

// ---------------------------------------------------------------- Aparición / desvanecido por scroll
/// Envuelve una sección: aparece con fundido al entrar y se difumina y atenúa al salir por arriba.
class _Reveal extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final bool first;
  const _Reveal({required this.controller, required this.child, this.first = false});
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  late double _in = widget.first ? 1 : 0;
  double _out = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaQuery.sizeOf(context); // recalcula si cambia el tamaño de la ventana
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final vh = MediaQuery.sizeOf(context).height - 72; // 72 = altura del menú
    final top = box.localToGlobal(Offset.zero).dy - 72;
    final i = ((vh - top) / (vh * .3)).clamp(0.0, 1.0); // entra: aparece al subir desde el borde inferior
    final o = ((vh * .35 - (top + box.size.height)) / (vh * .35)).clamp(0.0, 1.0); // sale: su final sube por arriba
    if ((i - _in).abs() > .004 || (o - _out).abs() > .004) {
      setState(() {
        _in = i;
        _out = o;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final vis = still ? 1.0 : _in * (1 - .8 * _out);
    final sigma = still ? 0.0 : 10 * _out;
    Widget c = _RevealScope(shown: still || (_in > .9 && _out < .1), child: widget.child);
    if (sigma > .3) {
      c = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal), child: c);
    }
    return IgnorePointer(
      ignoring: vis < .3,
      child: Opacity(
        opacity: vis,
        child: Transform.translate(offset: Offset(0, still ? 0 : (1 - _in) * 28), child: c),
      ),
    );
  }
}

/// Los iframes (mapa, YouTube) son elementos del navegador y no admiten fundido ni desenfoque:
/// solo se muestran cuando su sección está totalmente visible.
class _RevealScope extends InheritedWidget {
  final bool shown;
  const _RevealScope({required this.shown, required super.child});
  static bool of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<_RevealScope>()?.shown ?? true;
  @override
  bool updateShouldNotify(_RevealScope o) => o.shown != shown;
}

// ---------------------------------------------------------------- Hero
/// Horizonte de rascacielos con ventanas encendidas (siluetas sobre el degradado del cielo)
class _CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    const lit = [C.cyan, C.pink, C.yellow];
    void layer(double maxH, Color fill, double minW, double maxW, bool windows) {
      var x = -10.0;
      while (x < size.width) {
        final w = minW + rnd.nextDouble() * (maxW - minW);
        final h = maxH * (.25 + rnd.nextDouble() * .75);
        final top = size.height - h;
        canvas.drawRect(Rect.fromLTWH(x, top, w, h), Paint()..color = fill);
        if (windows) {
          for (var wy = top + 10; wy < size.height - 8; wy += 12) {
            for (var wx = x + 6; wx < x + w - 6; wx += 10) {
              if (rnd.nextDouble() < .16) {
                canvas.drawRect(Rect.fromLTWH(wx, wy, 4, 5), Paint()..color = lit[rnd.nextInt(3)].withValues(alpha: .85));
              }
            }
          }
        }
        x += w + 2 + rnd.nextDouble() * 6;
      }
    }

    layer(size.height * .95, const Color(0xFF1E0C40), 40, 90, false);
    layer(size.height * .62, C.ink, 34, 80, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Líneas de barrido tipo monitor CRT sobre toda la página
class _ScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x26000000);
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Texto con aberración cromática; cada pocos segundos "salta" como una señal con interferencias
class _Glitch extends StatefulWidget {
  final String text;
  final double size;
  final TextAlign align;
  const _Glitch(this.text, this.size, this.align);
  @override
  State<_Glitch> createState() => _GlitchState();
}

class _GlitchState extends State<_Glitch> {
  Timer? _t;
  bool _b = false;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 4200), (_) => _pulse());
  }

  Future<void> _pulse() async {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    for (final on in [true, false, true, false]) {
      if (!mounted) return;
      setState(() => _b = on);
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dx = _b ? 9.0 : 2.5;
    final dy = _b ? 2.0 : 0.0;
    Widget layer(Color c, double ox, double oy) => Transform.translate(
        offset: Offset(ox, oy),
        child: Text(widget.text, textAlign: widget.align, style: _h(widget.size, c, null, true)));
    return Stack(children: [
      layer(C.cyan.withValues(alpha: .8), -dx, -dy),
      layer(C.pink.withValues(alpha: .8), dx, dy),
      Text(widget.text, textAlign: widget.align, style: _h(widget.size, C.yellow, C.pink, true)),
    ]);
  }
}

Widget _blob(Color c, double s) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c.withValues(alpha: .20), c.withValues(alpha: 0)])),
    );

class _Hero extends StatelessWidget {
  final VoidCallback onTrailer, onTeam;
  const _Hero({super.key, required this.onTrailer, required this.onTeam});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width > 860;
    final still = MediaQuery.disableAnimationsOf(context);
    final al = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final text = Column(crossAxisAlignment: al, children: [
      _Glitch(Content.headline.toUpperCase(), wide ? 62 : 36, wide ? TextAlign.left : TextAlign.center),
      const SizedBox(height: 22),
      ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _p(Content.tagline, s: 19, c: C.text, a: wide ? TextAlign.left : TextAlign.center)),
      const SizedBox(height: 36),
      Wrap(spacing: 16, runSpacing: 14, alignment: wide ? WrapAlignment.start : WrapAlignment.center, children: [
        _Btn('Watch the trailer', onTrailer, icon: Icons.play_arrow_rounded),
        if (Content.demoUrl.isNotEmpty) _Btn('Play the demo', () => _open(Content.demoUrl), primary: false)
        else _Btn('Meet the team', onTeam, primary: false),
      ]),
    ]);
    final glow = wide ? 540.0 : 340.0;
    final art = SizedBox(
      height: wide ? 500 : 300,
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        Container(
          width: glow,
          height: glow,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [C.cyan.withValues(alpha: .34), C.cyan.withValues(alpha: 0)])),
        ),
        Image.asset('assets/logo.png',
            height: wide ? 400 : 250,
            semanticLabel: 'Barn Studio logo: an owl whose face is half light, half grey'),
      ]),
    );
    // El primer bloque ocupa toda la pantalla: de entrada solo se ve este
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.height - 72),
      child: Stack(alignment: Alignment.center, children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [C.ink, Color(0xFF2A0F55), Color(0xFF7A1470)],
                  stops: [0, .62, 1]),
            ),
          ),
        ),
        Positioned(left: -160, top: -200, child: _blob(C.cyan, 460)),
        Positioned(right: -160, top: -120, child: _blob(C.pink, 460)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: wide ? 340 : 220,
          child: RepaintBoundary(child: CustomPaint(painter: _CityPainter())),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(wide ? 48 : 20, wide ? 56 : 32, wide ? 48 : 20, wide ? 150 : 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: still ? 1 : 0, end: 1),
                duration: still ? Duration.zero : const Duration(milliseconds: 1400),
                curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: child)),
                child: wide
                    ? Row(children: [Expanded(flex: 6, child: text), const SizedBox(width: 32), Expanded(flex: 5, child: art)])
                    : Column(children: [art, const SizedBox(height: 24), text]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Contenedor de sección
class _Section extends StatelessWidget {
  final String title;
  final String? intro;
  final Color bg;
  final Widget child;
  final Color glow;
  final String? tag;
  const _Section({required this.title, required this.child, this.intro, this.bg = C.ink, this.glow = C.pink, this.tag});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 860;
    return Container(
      width: double.infinity,
      color: bg,
      padding: EdgeInsets.symmetric(vertical: wide ? 96 : 64, horizontal: wide ? 48 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (tag != null) ...[
              Text(tag!, style: const TextStyle(color: C.cyan, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 4)),
              const SizedBox(height: 10),
            ],
            Text(title, style: _rune(wide ? 56 : 40, C.yellow, glow)),
            if (intro != null) ...[
              const SizedBox(height: 14),
              ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: _p(intro!)),
            ],
            const SizedBox(height: 44),
            child,
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Iframe (YouTube y Google Maps)
class _Iframe extends StatelessWidget {
  final String url, title;
  const _Iframe(this.url, this.title);

  @override
  Widget build(BuildContext context) => !_RevealScope.of(context)
      ? const ColoredBox(color: C.card)
      : HtmlElementView.fromTagName(
        tagName: 'iframe',
        onElementCreated: (Object e) {
          final f = e as web.HTMLIFrameElement;
          f.src = url;
          f.title = title;
          f.allowFullscreen = true;
          f.allow = 'autoplay; encrypted-media; picture-in-picture';
          f.style.border = 'none';
          f.style.width = '100%';
          f.style.height = '100%';
        },
      );
}

// ---------------------------------------------------------------- Juego: tráiler y galería
class _GameSection extends StatelessWidget {
  const _GameSection({super.key});

  @override
  Widget build(BuildContext context) => _Section(
        title: Content.gameTitle,
        intro: Content.gameText,
        glow: C.cyan,
        tag: '01 // GAME',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Tags(),
          const SizedBox(height: 32),
          const _Trailer(),
          const SizedBox(height: 56),
          Text('What to Expect', style: _h(30)),
          const SizedBox(height: 24),
          const _Pillars(),
          const SizedBox(height: 56),
          Text('Gallery', style: _h(30)),
          const SizedBox(height: 24),
          const _Gallery(),
        ]),
      );
}

class _Tags extends StatelessWidget {
  const _Tags();

  @override
  Widget build(BuildContext context) => Wrap(spacing: 10, runSpacing: 10, children: [
        for (final (i, t) in Content.tags.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: C.neon[i % 3].withValues(alpha: .08),
              shape: _bevel(8, C.neon[i % 3]),
              shadows: [BoxShadow(color: C.neon[i % 3].withValues(alpha: .35), blurRadius: 12)],
            ),
            child: Text(t.toUpperCase(),
                style: TextStyle(color: C.neon[i % 3], fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.5)),
          ),
      ]);
}

class _Pillars extends StatelessWidget {
  const _Pillars();

  @override
  Widget build(BuildContext context) => Wrap(spacing: 20, runSpacing: 20, children: [
        for (final (i, (icon, title, text)) in Content.pillars.indexed)
          _Card(
            width: 340,
            glow: C.neon[i % 3],
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 34, color: C.neon[i % 3]),
              const SizedBox(height: 16),
              Text(title, style: _h(24)),
              const SizedBox(height: 8),
              _p(text, s: 16),
            ]),
          ),
      ]);
}

class _Trailer extends StatefulWidget {
  const _Trailer();
  @override
  State<_Trailer> createState() => _TrailerState();
}

class _TrailerState extends State<_Trailer> {
  bool _play = false;

  @override
  Widget build(BuildContext context) {
    final ready = Content.trailerId.isNotEmpty;
    return ClipPath(
      clipper: ShapeBorderClipper(shape: _bevel(26)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _play
            ? _Iframe('https://www.youtube-nocookie.com/embed/${Content.trailerId}?autoplay=1&rel=0', 'Official trailer')
            : _Hover(
                onTap: ready ? () => setState(() => _play = true) : null,
                lift: 0,
                builder: (h) => AnimatedContainer(
                  duration: _d(context),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(color: C.card, shape: _bevel(26, ready && h ? C.yellow : C.line, 1.5)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedScale(
                      scale: h && ready ? 1.15 : 1,
                      duration: _d(context),
                      child: Icon(ready ? Icons.play_circle_fill : Icons.movie_outlined, size: 88, color: C.yellow),
                    ),
                    const SizedBox(height: 12),
                    Text(ready ? 'Watch the official trailer' : 'Trailer coming soon',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: .5)),
                  ]),
                ),
              ),
      ),
    );
  }
}

Widget _missing(int i) => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.image_outlined, color: C.muted, size: 36),
        const SizedBox(height: 8),
        Text('Screenshot ${i + 1}', style: const TextStyle(color: C.muted)),
      ]),
    );

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, b) {
        final cols = b.maxWidth > 800 ? 3 : (b.maxWidth > 520 ? 2 : 1);
        final w = (b.maxWidth - 16 * (cols - 1)) / cols;
        return Wrap(spacing: 16, runSpacing: 16, children: [
          for (final (i, p) in Content.gallery.indexed)
            SizedBox(
              width: w,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _Hover(
                  lift: 0,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      shape: _bevel(18, C.cyan),
                      child: InteractiveViewer(
                          child: Image.asset(p, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _missing(i))),
                    ),
                  ),
                  builder: (h) => ClipPath(
                    clipper: ShapeBorderClipper(shape: _bevel(22)),
                    child: Stack(fit: StackFit.expand, children: [
                      const ColoredBox(color: C.card),
                      AnimatedScale(
                        scale: h ? 1.07 : 1,
                        duration: _d(context, 350),
                        curve: Curves.easeOut,
                        child: Image.asset(p,
                            fit: BoxFit.cover,
                            semanticLabel: 'Game screenshot ${i + 1}',
                            errorBuilder: (_, __, ___) => _missing(i)),
                      ),
                      AnimatedOpacity(
                        opacity: h ? 1 : 0,
                        duration: _d(context),
                        child: Container(
                          color: C.ink.withValues(alpha: .55),
                          child: const Icon(Icons.zoom_in, size: 44, color: C.yellow, shadows: [Shadow(color: C.yellow, blurRadius: 20)]),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: _d(context),
                            decoration: ShapeDecoration(shape: _bevel(22, h ? C.yellow : C.line, 2)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ]);
      });
}

// ---------------------------------------------------------------- Documentación técnica
class _DocsSection extends StatelessWidget {
  const _DocsSection({super.key});

  @override
  Widget build(BuildContext context) => _Section(
        title: 'Technical Documentation',
        tag: '02 // DATA',
        intro: 'Everything behind the game: design, costs and how development is progressing.',
        bg: C.night,
        child: Column(children: [
          Wrap(spacing: 20, runSpacing: 20, children: const [
            _DocCard(Icons.description_outlined, 'Game Design Document',
                'Mechanics, map structure, masks and narrative of The Owl Path, explained step by step.', Content.gddUrl),
            _DocCard(Icons.payments_outlined, 'Production Budget',
                'Costs, timeline and resources needed to finish the game.', Content.budgetUrl),
            _DocCard(Icons.bar_chart, 'Development Charts',
                'Completed tasks, hours spent and the status of each area.', Content.chartsUrl),
          ]),
          const SizedBox(height: 20),
          const _BudgetBars(),
        ]),
      );
}

class _DocCard extends StatelessWidget {
  final IconData icon;
  final String title, text, url;
  const _DocCard(this.icon, this.title, this.text, this.url);

  @override
  Widget build(BuildContext context) => _Card(
        width: 340,
        onTap: url.isEmpty ? null : () => _open(url),
        lift: url.isNotEmpty,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 34, color: C.cyan),
          const SizedBox(height: 16),
          Text(title, style: _h(24)),
          const SizedBox(height: 8),
          _p(text, s: 16),
          const SizedBox(height: 20),
          if (url.isEmpty)
            const Text('Coming soon', style: TextStyle(color: C.muted, fontWeight: FontWeight.w600, fontSize: 16))
          else
            const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Open document', style: TextStyle(color: C.cyan, fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 18, color: C.cyan),
            ]),
        ]),
      );
}

class _BudgetBars extends StatelessWidget {
  const _BudgetBars();

  @override
  Widget build(BuildContext context) => _Card(
        width: double.infinity,
        lift: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Budget Breakdown', style: _h(24)),
          const SizedBox(height: 20),
          for (final (i, (label, v)) in Content.budget.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                SizedBox(width: 110, child: Text(label)),
                Expanded(
                  child: Stack(children: [
                    Container(height: 10, color: C.line),
                    FractionallySizedBox(
                      widthFactor: v / 100,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: C.neon[i % 3],
                          boxShadow: [BoxShadow(color: C.neon[i % 3].withValues(alpha: .8), blurRadius: 10)],
                        ),
                      ),
                    ),
                  ]),
                ),
                SizedBox(width: 56, child: Text('$v %', textAlign: TextAlign.right)),
              ]),
            ),
        ]),
      );
}

// ---------------------------------------------------------------- Sobre nosotros
class _AboutSection extends StatelessWidget {
  const _AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    const accents = C.neon;
    return _Section(
      title: 'About Us',
      tag: '03 // CREW',
      intro: 'Our vision is to create games that resonate emotionally with the people who play them.',
      child: Wrap(spacing: 20, runSpacing: 20, children: [
        for (final (i, (name, role, bio)) in Content.team.indexed)
          _Card(
            width: 340,
            glow: accents[i % 3],
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 32, backgroundColor: accents[i % 3], child: Text(name[0], style: _h(28, C.ink))),
              const SizedBox(height: 16),
              Text(name, style: _h(26)),
              const SizedBox(height: 4),
              Text(role, style: TextStyle(color: accents[i % 3], fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _p(bio, s: 16),
            ]),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Calendario
class _EventsSection extends StatelessWidget {
  const _EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Content.events.length;
    return _Section(
      title: 'Calendar',
      tag: '04 // TIMELINE',
      intro: 'Events and festivals where you can find us.',
      bg: C.night,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(children: [
          for (final (i, e) in Content.events.indexed)
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  width: 32,
                  child: Column(children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.$4 ? C.cyan : C.night,
                        border: Border.all(color: e.$4 ? C.cyan : C.pink, width: 2),
                        boxShadow: [BoxShadow(color: (e.$4 ? C.cyan : C.pink).withValues(alpha: .7), blurRadius: 10)],
                      ),
                    ),
                    if (i < n - 1) Expanded(child: Container(width: 2, color: C.line)),
                  ]),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.$4 ? '${e.$1} (done)' : e.$1,
                          style: TextStyle(color: e.$4 ? C.cyan : C.pink, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(e.$2, style: _h(26)),
                      const SizedBox(height: 6),
                      _p(e.$3, s: 16),
                    ]),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- Contacto y comunidad
class _ContactSection extends StatelessWidget {
  const _ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 860;
    final side = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Follow Us', style: _h(30)),
      const SizedBox(height: 12),
      _p('Share your theories about the masks and follow the development of The Owl Path.', s: 16),
      const SizedBox(height: 24),
      Wrap(spacing: 12, runSpacing: 12, children: [
        for (final (i, (icon, label, url)) in Content.socials.indexed)
          _Btn(label, () => _open(url), primary: false, icon: icon, color: C.neon[i % 3]),
      ]),
    ]);
    return _Section(
      title: 'Contact and Community',
      tag: '05 // COMMS',
      intro: 'Try the game, tell us what you think and join the conversation.',
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Expanded(child: _FeedbackForm()),
              const SizedBox(width: 56),
              Expanded(child: side),
            ])
          : Column(children: [const _FeedbackForm(), const SizedBox(height: 48), side]),
    );
  }
}

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm();
  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final _k = GlobalKey<FormState>();
  final _name = TextEditingController(), _mail = TextEditingController(), _msg = TextEditingController();
  int _stars = 0;
  bool _busy = false, _ok = false;
  String? _status;

  @override
  void dispose() {
    _name.dispose();
    _mail.dispose();
    _msg.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_k.currentState!.validate()) return;
    setState(() => _busy = true);
    final text = 'Name: ${_name.text}\nEmail: ${_mail.text}\nRating: $_stars/5\n\n${_msg.text}';
    bool ok;
    try {
      if (Content.formEndpoint.isNotEmpty) {
        final r = await http.post(
          Uri.parse(Content.formEndpoint),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'name': _name.text, 'email': _mail.text, 'rating': _stars, 'message': _msg.text}),
        );
        ok = r.statusCode < 300;
      } else {
        ok = await launchUrl(Uri.parse(
            'mailto:${Content.email}?subject=${Uri.encodeComponent('Feedback on ${Content.gameTitle}')}&body=${Uri.encodeComponent(text)}'));
      }
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _ok = ok;
      _status = ok ? 'Thank you! We have received your feedback.' : 'Could not send it. Write to us at ${Content.email}.';
    });
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _k,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tell Us What You Think', style: _h(30)),
          const SizedBox(height: 20),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@') || !v.contains('.')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Rating', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            for (var n = 1; n <= 5; n++)
              IconButton(
                tooltip: '$n of 5',
                onPressed: () => setState(() => _stars = n),
                icon: Icon(n <= _stars ? Icons.star : Icons.star_border, color: C.yellow, size: 30),
              ),
          ]),
          const SizedBox(height: 4),
          TextFormField(
            controller: _msg,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Your feedback'),
            validator: (v) => (v == null || v.trim().length < 10) ? 'Tell us a little more (at least 10 characters)' : null,
          ),
          const SizedBox(height: 20),
          _Btn(_busy ? 'Sending…' : 'Send feedback', _busy ? null : _send),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(_status!,
                  style: TextStyle(color: _ok ? C.cyan : const Color(0xFFFF8A80), fontWeight: FontWeight.w600)),
            ),
        ]),
      );
}

// ---------------------------------------------------------------- Pie
class _Footer extends StatelessWidget {
  final VoidCallback onTop;
  const _Footer({required this.onTop});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: C.deep,
        padding: const EdgeInsets.all(32),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          spacing: 24,
          children: [
            const Text('© 2026 Barn Studio. All rights reserved.', style: TextStyle(color: C.muted)),
            _Btn('Back to top', onTop, primary: false, icon: Icons.keyboard_arrow_up),
          ],
        ),
      );
}