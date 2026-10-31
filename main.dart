import 'package:flutter/material.dart';

void main() => runApp(const TyreGuardApp());

class TyreGuardApp extends StatelessWidget {
  const TyreGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF17252D);
    const teal = Color(0xFF20B889);
    return MaterialApp(
      title: 'TyreGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.light,
          surface: const Color(0xFFF5F7F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F8),
          foregroundColor: navy,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFE8ECEE)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

enum PressureStatus { good, medium, warning, low }

class TyreReading {
  const TyreReading({required this.label, required this.psi});
  final String label;
  final double psi;

  PressureStatus get status {
    // DEMO ONLY: percentage of the example target pressure (36 PSI).
    final ratio = psi / 36;
    if (ratio >= .90) return PressureStatus.good;
    if (ratio >= .80) return PressureStatus.medium;
    if (ratio >= .70) return PressureStatus.warning;
    return PressureStatus.low;
  }

  String get statusLabel => switch (status) {
        PressureStatus.good => 'GOOD',
        PressureStatus.medium => 'MEDIUM',
        PressureStatus.warning => 'WARNING',
        PressureStatus.low => 'LOW / CRITICAL',
      };

  Color get color => switch (status) {
        PressureStatus.good => const Color(0xFF159B68),
        PressureStatus.medium => const Color(0xFFD5A21B),
        PressureStatus.warning => const Color(0xFFE8892D),
        PressureStatus.low => const Color(0xFFD83D3D),
      };

  String get advice => switch (status) {
        PressureStatus.good => 'Pressure is in the demo healthy range.',
        PressureStatus.medium => 'Pressure is decreasing. Check soon.',
        PressureStatus.warning => 'Fill air soon. Do not ignore this warning.',
        PressureStatus.low => 'Pressure is critically low. Stop and check safely.',
      };
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  double _frontPsi = 36;
  double _rearPsi = 36;

  TyreReading get front => TyreReading(label: 'Front tyre', psi: _frontPsi);
  TyreReading get rear => TyreReading(label: 'Rear tyre', psi: _rearPsi);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _garage(),
      _alerts(),
      _settings(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF17252D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 10),
            const Text('TyreGuard', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => setState(() => _tab = 2),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.two_wheeler_outlined), selectedIcon: Icon(Icons.two_wheeler), label: 'Garage'),
          NavigationDestination(icon: Icon(Icons.notifications_active_outlined), selectedIcon: Icon(Icons.notifications_active), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final worst = [_frontPsi, _rearPsi].reduce((a, b) => a < b ? a : b);
    final overall = TyreReading(label: 'Overall', psi: worst);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MY VEHICLE', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: Color(0xFF718087), fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Electric Scooter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF17252D))),
                ],
              ),
            ),
            _connectionPill(),
          ],
        ),
        const SizedBox(height: 16),
        _vehicleHero(),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: Text('Tyre pressure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            Text('DEMO DATA', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.orange.shade800, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _tyreCard(front)),
            const SizedBox(width: 12),
            Expanded(child: _tyreCard(rear)),
          ],
        ),
        const SizedBox(height: 14),
        _overallCard(overall),
        const SizedBox(height: 18),
        const Text('Try the alert simulator', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('Move the sliders to preview the four warning levels. These are not live sensor readings.', style: TextStyle(color: Color(0xFF718087), height: 1.4)),
        const SizedBox(height: 12),
        _simulator('Front tyre', _frontPsi, (v) => setState(() => _frontPsi = v)),
        const SizedBox(height: 10),
        _simulator('Rear tyre', _rearPsi, (v) => setState(() => _rearPsi = v)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() { _frontPsi = 36; _rearPsi = 36; }),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset demo readings'),
        ),
        const SizedBox(height: 10),
        const _InfoNote(),
      ],
    );
  }

  Widget _connectionPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFFFF3E5), borderRadius: BorderRadius.circular(30)),
        child: const Row(
          children: [
            Icon(Icons.bluetooth_disabled, size: 15, color: Color(0xFFB86A18)),
            SizedBox(width: 5),
            Text('Not connected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9A5A17))),
          ],
        ),
      );

  Widget _vehicleHero() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF17252D), Color(0xFF293F49)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('ELECTRIC MOBILITY', style: TextStyle(color: Color(0xFFB9C9CE), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                Spacer(),
                Icon(Icons.bolt_rounded, color: Color(0xFF8DE6C4)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 135,
              child: Center(
                child: Icon(Icons.electric_scooter_rounded, size: 125, color: Colors.white.withValues(alpha: .94)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Your ride. Your safety.', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Front and rear tyre monitoring', style: TextStyle(color: Color(0xFFB9C9CE), fontSize: 12)),
          ],
        ),
      );

  Widget _tyreCard(TyreReading reading) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8ECEE))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reading.label.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Color(0xFF718087), fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(reading.psi.toStringAsFixed(1), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: Color(0xFF17252D))),
                const Padding(padding: EdgeInsets.only(bottom: 5, left: 4), child: Text('PSI', style: TextStyle(fontSize: 11, color: Color(0xFF718087), fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 8),
            _statusChip(reading),
          ],
        ),
      );

  Widget _statusChip(TyreReading reading) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: reading.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: reading.color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(child: Text(reading.statusLabel, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: reading.color))),
          ],
        ),
      );

  Widget _overallCard(TyreReading reading) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF17252D), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(Icons.health_and_safety_outlined, color: reading.color, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('OVERALL TYRE STATUS', style: TextStyle(color: Color(0xFFB9C9CE), fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(reading.statusLabel, style: TextStyle(color: reading.color, fontSize: 17, fontWeight: FontWeight.w900)),
                Text(reading.advice, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
              ]),
            ),
          ],
        ),
      );

  Widget _simulator(String label, double value, ValueChanged<double> onChanged) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${value.toStringAsFixed(1)} PSI', style: const TextStyle(fontWeight: FontWeight.w800))]),
              Slider(min: 10, max: 40, divisions: 60, value: value, onChanged: onChanged),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('LOW', style: TextStyle(fontSize: 9, color: Color(0xFFD83D3D), fontWeight: FontWeight.w800)),
                Text('WARNING', style: TextStyle(fontSize: 9, color: Color(0xFFE8892D), fontWeight: FontWeight.w800)),
                Text('MEDIUM', style: TextStyle(fontSize: 9, color: Color(0xFFD5A21B), fontWeight: FontWeight.w800)),
                Text('GOOD', style: TextStyle(fontSize: 9, color: Color(0xFF159B68), fontWeight: FontWeight.w800)),
              ]),
            ],
          ),
        ),
      );

  Widget _garage() => _simplePage(
        icon: Icons.two_wheeler_rounded,
        title: 'My Garage',
        subtitle: 'Your vehicles will appear here.',
        child: FilledButton.icon(
          onPressed: () => _message('Vehicle profiles are coming in the next build.'),
          icon: const Icon(Icons.add),
          label: const Text('Add a vehicle'),
        ),
      );

  Widget _alerts() => _simplePage(
        icon: Icons.notifications_active_outlined,
        title: 'Alerts',
        subtitle: 'Pressure warnings and sensor notifications will appear here.',
        child: Column(children: [
          _legend(Colors.green, 'Green', 'Pressure in recommended range'),
          _legend(const Color(0xFFD5A21B), 'Yellow', 'Medium — check soon'),
          _legend(const Color(0xFFE8892D), 'Orange', 'Warning — fill air soon'),
          _legend(const Color(0xFFD83D3D), 'Red', 'Low / critical — act immediately'),
        ]),
      );

  Widget _settings() => _simplePage(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'Configure units, alerts and sensor preferences.',
        child: Column(children: const [
          ListTile(leading: Icon(Icons.straighten), title: Text('Pressure unit'), subtitle: Text('PSI (demo default)')),
          Divider(),
          ListTile(leading: Icon(Icons.bluetooth), title: Text('TPMS connection'), subtitle: Text('Not connected')),
          Divider(),
          ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notifications'), subtitle: Text('Available after alert integration')),
        ]),
      );

  Widget _simplePage({required IconData icon, required String title, required String subtitle, required Widget child}) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 54, color: const Color(0xFF159B68)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF718087))),
            const SizedBox(height: 22),
            child,
          ]),
        ),
      );

  Widget _legend(Color color, String title, String detail) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(radius: 8, backgroundColor: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(detail),
      );

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFFEAF3F1), borderRadius: BorderRadius.circular(16)),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Color(0xFF267C68), size: 19),
            SizedBox(width: 9),
            Expanded(child: Text('Prototype only: pressure values and thresholds are simulated examples. A compatible TPMS sensor and vehicle-specific recommended cold pressure are required for real readings and safe alerts.', style: TextStyle(fontSize: 11, color: Color(0xFF315D53), height: 1.45))),
          ],
        ),
      );
}
