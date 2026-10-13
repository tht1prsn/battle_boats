import 'package:battle_boats/screens/start_screen.dart';
import 'package:battle_boats/widgets/join_lobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('Join Lobby opens the code dialog and Cancel closes it',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StartScreen()));

    await tester.tap(find.text('Join Lobby'));
    await tester.pumpAndSettle();
    expect(find.byType(JoinLobbyDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(JoinLobbyDialog), findsNothing);
    // cancelling should not try to join anything
    expect(find.byType(SnackBar), findsNothing);
  });
}