import 'package:flutter/material.dart';

// popup to let people join lobbies
class JoinLobbyDialog extends StatefulWidget {
  const JoinLobbyDialog({super.key});

  @override
  State<JoinLobbyDialog> createState() => _JoinLobbyDialogState();
}

class _JoinLobbyDialogState extends State<JoinLobbyDialog> {
  // holds what players type in 
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // sends the code to teh caller
  void _submit() {
    // generalizing uppercase and trimmed
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Lobby'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: 'Enter lobby code'),
        // 'done' and 'join' both work super cool
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Join'),
        ),
      ],
    );
  }
}