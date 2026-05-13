import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../core/storage.dart';

class ChatScreen extends StatefulWidget {
  final String applicationId;

  const ChatScreen({Key? key, required this.applicationId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();

  void _sendMessage({bool isOffer = false}) async {
    if (_msgCtrl.text.isEmpty && !isOffer) return;

    final user = LocalStorage().currentUser;
    if (user == null) return;

    final msg = ChatMessage(
      id: const Uuid().v4(),
      applicationId: widget.applicationId,
      senderId: user.id,
      content: isOffer ? 'Negotiation Offer: ₹${_msgCtrl.text}/mo' : _msgCtrl.text,
      timestamp: DateTime.now(),
      isSystemOffer: isOffer,
    );

    await LocalStorage().saveMessage(msg);
    _msgCtrl.clear();
    setState(() {});
  }

  void _handleOfferResponse(bool accepted) async {
    final apps = LocalStorage().getApplications();
    final app = apps.firstWhere((a) => a.id == widget.applicationId);
    
    final updatedApp = app.copyWith(status: accepted ? 'selected' : 'rejected');
    await LocalStorage().saveApplication(updatedApp);

    final user = LocalStorage().currentUser;
    final msg = ChatMessage(
      id: const Uuid().v4(),
      applicationId: widget.applicationId,
      senderId: user!.id,
      content: accepted ? 'Offer Accepted!' : 'Offer Rejected.',
      timestamp: DateTime.now(),
      isSystemOffer: false,
    );
    await LocalStorage().saveMessage(msg);

    if (!mounted) return;
    setState(() {});
    
    if (accepted || !accepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accepted ? 'Job Finalized!' : 'Job Rejected')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = LocalStorage().currentUser;
    final messages = LocalStorage().getMessages(widget.applicationId);
    final app = LocalStorage().getApplications().firstWhere((a) => a.id == widget.applicationId);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat & Negotiate')),
      body: Column(
        children: [
          if (app.status == 'selected')
            Container(
              color: Colors.green[100],
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text('Job Finalized! You can both now proceed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                final isMe = msg.senderId == currentUser?.id;

                if (msg.isSystemOffer && !isMe && app.status == 'accepted') {
                  return Card(
                    color: Colors.purple[50],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(msg.content, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _handleOfferResponse(true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () => _handleOfferResponse(false),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.purple : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (app.status == 'accepted')
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(hintText: 'Type message or amount...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.local_offer, color: Colors.orange),
                    tooltip: 'Send as Offer',
                    onPressed: () => _sendMessage(isOffer: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.purple),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
