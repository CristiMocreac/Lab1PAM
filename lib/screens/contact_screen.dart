import 'package:flutter/material.dart';

/// Local interaction preview: no message or call is sent to a clinic.
class ContactScreen extends StatefulWidget {
  final String doctorName, action;
  const ContactScreen({
    required this.doctorName,
    required this.action,
    super.key,
  });
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final controller = TextEditingController();
  final messages = <String>[];
  bool muted = false, camera = true;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() => messages.add(text));
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.action == 'message';
    final video = widget.action == 'videoCall';
    return Scaffold(
      appBar: AppBar(title: Text(widget.doctorName)),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Local demo • No connection to a clinic',
                textAlign: TextAlign.center,
              ),
            ),
            if (chat) ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (messages.isEmpty)
                      const Text(
                        'Write a message to preview the conversation.',
                      ),
                    ...messages.map(
                      (text) => Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('$text\nSaved locally in this preview'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onSubmitted: (_) => send(),
                        decoration: const InputDecoration(
                          hintText: 'Write a message',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Save message in preview',
                      onPressed: send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        video && camera
                            ? Icons.videocam_outlined
                            : Icons.person_outline,
                        size: 96,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        video ? 'Video call preview' : 'Voice call preview',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Text('Not connected'),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 20,
                children: [
                  IconButton.filledTonal(
                    tooltip: muted ? 'Unmute' : 'Mute',
                    onPressed: () => setState(() => muted = !muted),
                    icon: Icon(muted ? Icons.mic_off : Icons.mic),
                  ),
                  if (video)
                    IconButton.filledTonal(
                      tooltip: camera ? 'Turn camera off' : 'Turn camera on',
                      onPressed: () => setState(() => camera = !camera),
                      icon: Icon(camera ? Icons.videocam : Icons.videocam_off),
                    ),
                  IconButton.filled(
                    tooltip: 'Close call preview',
                    style: IconButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_end),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
