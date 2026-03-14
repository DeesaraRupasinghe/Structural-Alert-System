import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ConstructionSafetyApp());
}

class ConstructionSafetyApp extends StatelessWidget {
  const ConstructionSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction Safety Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SafetyDashboard(),
    );
  }
}

class SafetyDashboard extends StatelessWidget {
  const SafetyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference sensorRef =
        FirebaseDatabase.instance.ref('sensorData');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Safety Monitor'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: sensorRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading sensor data'));
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final int soilMoisture = (data['soilMoisture'] ?? 0) as int;
          final int vibration = (data['vibration'] ?? 0) as int;
          final double tiltX = (data['tiltX'] ?? 0.0).toDouble();
          final double tiltY = (data['tiltY'] ?? 0.0).toDouble();
          final int distance = (data['distance'] ?? 0) as int;

          return DashboardContent(
            soilMoisture: soilMoisture,
            vibration: vibration,
            tiltX: tiltX,
            tiltY: tiltY,
            distance: distance,
          );
        },
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final int soilMoisture;
  final int vibration;
  final double tiltX;
  final double tiltY;
  final int distance;

  const DashboardContent({
    super.key,
    required this.soilMoisture,
    required this.vibration,
    required this.tiltX,
    required this.tiltY,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> warnings = _buildWarnings();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...warnings,
          if (warnings.isNotEmpty) const SizedBox(height: 8),
          _buildSensorCard(
            icon: Icons.water_drop,
            label: 'Soil Moisture',
            value: '$soilMoisture',
            color: _soilMoistureColor(),
          ),
          _buildSensorCard(
            icon: Icons.vibration,
            label: 'Vibration Status',
            value: vibration == 1 ? 'DETECTED' : 'Normal',
            color: vibration == 1 ? Colors.red : Colors.green,
          ),
          _buildSensorCard(
            icon: Icons.screen_rotation,
            label: 'Tilt X',
            value: '${tiltX.toStringAsFixed(2)}°',
            color: _tiltColor(tiltX),
          ),
          _buildSensorCard(
            icon: Icons.screen_rotation,
            label: 'Tilt Y',
            value: '${tiltY.toStringAsFixed(2)}°',
            color: _tiltColor(tiltY),
          ),
          _buildSensorCard(
            icon: Icons.straighten,
            label: 'Distance (mm)',
            value: '$distance mm',
            color: _distanceColor(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWarnings() {
    final List<Widget> warnings = [];

    if (vibration == 1) {
      warnings.add(const WarningBanner(
        message: '⚠ STRUCTURAL MOVEMENT DETECTED',
        color: Colors.red,
      ));
    }

    if (tiltX.abs() > 15 || tiltY.abs() > 15) {
      warnings.add(const WarningBanner(
        message: '⚠ STRUCTURE LEANING',
        color: Colors.red,
      ));
    }

    if (distance < 50) {
      warnings.add(const WarningBanner(
        message: '⚠ DISPLACEMENT DETECTED',
        color: Colors.red,
      ));
    }

    return warnings;
  }

  Color _soilMoistureColor() {
    if (soilMoisture > 700) return Colors.red;
    if (soilMoisture > 400) return Colors.orange;
    return Colors.green;
  }

  Color _tiltColor(double tilt) {
    final double absTilt = tilt.abs();
    if (absTilt > 15) return Colors.red;
    if (absTilt > 10) return Colors.orange;
    return Colors.green;
  }

  Color _distanceColor() {
    if (distance < 50) return Colors.red;
    if (distance < 100) return Colors.orange;
    return Colors.green;
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class WarningBanner extends StatelessWidget {
  final String message;
  final Color color;

  const WarningBanner({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
