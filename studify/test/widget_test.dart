// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:studify/main.dart';

void main() {
  testWidgets('Login screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudifyApp());

    // Verify that the login screen is displayed
    expect(find.text('Studify'), findsOneWidget);
    expect(find.text('Gestion des Absences'), findsOneWidget);
    expect(find.text('Nom d\'utilisateur'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });
}
