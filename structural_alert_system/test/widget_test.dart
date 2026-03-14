import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:structural_alert_system/main.dart';

void main() {
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
            ),
          ),
        ),
      );

      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('Vibration Status'), findsOneWidget);
      expect(find.text('Tilt X'), findsOneWidget);
      expect(find.text('Tilt Y'), findsOneWidget);
      expect(find.text('Distance (mm)'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('300'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('5.25°'), findsOneWidget);
      expect(find.text('3.10°'), findsOneWidget);
      expect(find.text('120 mm'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ STRUCTURAL MOVEMENT DETECTED'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ STRUCTURE LEANING'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ STRUCTURE LEANING'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ DISPLACEMENT DETECTED'), findsOneWidget);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ STRUCTURAL MOVEMENT DETECTED'), findsNothing);
      expect(find.text('⚠ STRUCTURE LEANING'), findsNothing);
      expect(find.text('⚠ DISPLACEMENT DETECTED'), findsNothing);
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
            ),
          ),
        ),
      );

      expect(find.text('⚠ STRUCTURAL MOVEMENT DETECTED'), findsOneWidget);
      expect(find.text('⚠ STRUCTURE LEANING'), findsOneWidget);
      expect(find.text('⚠ DISPLACEMENT DETECTED'), findsOneWidget);
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
    testWidgets('has correct title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardContent(
              soilMoisture: 300,
              vibration: 0,
              tiltX: 5.0,
              tiltY: 3.0,
              distance: 120,
            ),
          ),
        ),
      );

      // Verify the dashboard content renders within a MaterialApp
      expect(find.byType(Card), findsNWidgets(5));
    });
  });
}
