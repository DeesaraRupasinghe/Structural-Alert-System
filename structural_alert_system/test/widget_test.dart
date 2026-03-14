import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:structural_alert_system/main.dart';

void main() {
  group('SensorLog', () {
    test('fromMap creates correct SensorLog', () {
      final map = {
        'soilMoisture': 2608,
        'vibration': 0,
        'tiltX': 0.42377,
        'tiltY': -0.34237,
        'timestamp': 7024,
        'distance': 42240,
      };

      final log = SensorLog.fromMap(map);

      expect(log.soilMoisture, 2608);
      expect(log.vibration, 0);
      expect(log.tiltX, closeTo(0.42377, 0.001));
      expect(log.tiltY, closeTo(-0.34237, 0.001));
      expect(log.timestamp, 7024);
      expect(log.distance, 42240);
    });

    test('fromMap handles missing values with defaults', () {
      final map = <String, dynamic>{};

      final log = SensorLog.fromMap(map);

      expect(log.soilMoisture, 0);
      expect(log.vibration, 0);
      expect(log.tiltX, 0.0);
      expect(log.tiltY, 0.0);
      expect(log.timestamp, 0);
      expect(log.distance, 0);
    });
  });

  group('DashboardContent', () {
    testWidgets('displays all sensor labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('Vibration Status'), findsOneWidget);
      expect(find.text('Tilt X'), findsOneWidget);
      expect(find.text('Tilt Y'), findsOneWidget);
      expect(find.text('Distance (mm)'), findsOneWidget);
      expect(find.text('Timestamp'), findsOneWidget);
    });

    testWidgets('displays sensor values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.25,
              tiltY: 3.10,
              distance: 120,
              timestamp: 12587,
            ),
          ),
        ),
      );

      expect(find.text('300'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('5.25°'), findsOneWidget);
      expect(find.text('3.10°'), findsOneWidget);
      expect(find.text('120 mm'), findsOneWidget);
      expect(find.text('12587'), findsOneWidget);
    });

    testWidgets('shows vibration warning when vibration == 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 1,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(
          find.text(
              '⚠ Vibration Detected – Possible Structural Movement'),
          findsOneWidget);
      expect(find.text('DETECTED'), findsOneWidget);
    });

    testWidgets('shows tilt warning when tiltX exceeds threshold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 16.0,
              tiltY: 3.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(find.text('⚠ Structure Leaning Risk'), findsOneWidget);
    });

    testWidgets('shows tilt warning when tiltY exceeds threshold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: -16.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(find.text('⚠ Structure Leaning Risk'), findsOneWidget);
    });

    testWidgets('shows displacement warning when distance < 50',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 40,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(
          find.text('⚠ Structural Displacement Detected'), findsOneWidget);
    });

    testWidgets('shows no warnings when all values are safe',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(
          find.text(
              '⚠ Vibration Detected – Possible Structural Movement'),
          findsNothing);
      expect(find.text('⚠ Structure Leaning Risk'), findsNothing);
      expect(
          find.text('⚠ Structural Displacement Detected'), findsNothing);
    });

    testWidgets('shows all warnings simultaneously',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 800,
              vibration: 1,
              tiltX: 20.0,
              tiltY: 18.0,
              distance: 30,
              timestamp: 7024,
            ),
          ),
        ),
      );

      expect(
          find.text(
              '⚠ Vibration Detected – Possible Structural Movement'),
          findsOneWidget);
      expect(find.text('⚠ Structure Leaning Risk'), findsOneWidget);
      expect(
          find.text('⚠ Structural Displacement Detected'), findsOneWidget);
    });
  });

  group('WarningBanner', () {
    testWidgets('displays the warning message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WarningBanner(
              message: 'Test Warning',
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Test Warning'), findsOneWidget);
    });
  });

  group('ConstructionSafetyApp', () {
    testWidgets('renders six sensor cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 120,
              timestamp: 7024,
            ),
          ),
        ),
      );

      // 6 cards: Soil Moisture, Vibration, Tilt X, Tilt Y, Distance, Timestamp
      expect(find.byType(Card), findsNWidgets(6));
    });
  });
}
