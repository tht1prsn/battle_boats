import 'package:battle_boats/widgets/join_lobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// remembers what the dialog sent back
class DialogResult {
  // when the dialog closes, it makes true
  bool closed = false;
  // the code that is sent back
  String? code;
}

// shows a button that opens JoinLobbyDialog the same way StartScreen does,
// taps it and returns an object we can check afterward
Future<DialogResult> openDialog(WidgetTester tester) async {
  final result = DialogResult();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              result.code = await showDialog<String>(
                context: context,
                builder: (_) => const JoinLobbyDialog(),
              );
              result.closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  // https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html
  await tester.pumpAndSettle(); 
  return result;
}

void main() {
  testWidgets('Join sends back the code trimmed and uppercased',
      (tester) async {
    final result = await openDialog(tester);

    await tester.enterText(find.byType(TextField), '  abc123 ');
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();

    expect(result.code, 'ABC123');
    expect(find.byType(JoinLobbyDialog), findsNothing);
  });

  testWidgets('empty or blank input does not close the dialog',
      (tester) async {
    final result = await openDialog(tester);

    // if nothing is typed
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(find.byType(JoinLobbyDialog), findsOneWidget);

    // if there are only spaces
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(find.byType(JoinLobbyDialog), findsOneWidget);
    expect(result.closed, isFalse);
  });
}