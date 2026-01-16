import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/chat_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final meCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _hasMessageText = false;
  bool _showContactField = true;

  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    msgCtrl.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    msgCtrl.removeListener(_onMessageChanged);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  bool get _isConnected =>
      context.read<ChatBloc>().state.connectionStatus ==
          ConnectionStatus.connected;

  String get _currentUserId =>
      context.read<ChatBloc>().state.userId ?? '';

  /* ---------------- TYPING ---------------- */
  void _onMessageChanged() {
    final hasText = msgCtrl.text.trim().isNotEmpty;

    if (_hasMessageText != hasText) {
      setState(() => _hasMessageText = hasText);
    }

    if (_isConnected && toCtrl.text.isNotEmpty) {
      _typingDebounce?.cancel();

      context.read<ChatBloc>().sendTyping(toCtrl.text);

      _typingDebounce = Timer(const Duration(seconds: 2), () {
        context.read<ChatBloc>().sendTyping(toCtrl.text);
      });
    }
  }

  void _sendMessage() {
    if (msgCtrl.text.isEmpty ||
        toCtrl.text.isEmpty ||
        _currentUserId.isEmpty) return;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        sender: _currentUserId,
        receiver: toCtrl.text,
        message: msgCtrl.text,
      ),
    );

    msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFECE5DD),

        /* ---------------- APP BAR ---------------- */
        appBar: AppBar(
          backgroundColor: const Color(0xFF075E54),
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final contact = toCtrl.text;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.isEmpty ? "New Chat" : "Chat with $contact",
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (contact.isNotEmpty)
                    Text(
                      state.typingUser == contact
                          ? "typing..."
                          : state.isOnline(contact)
                          ? "online"
                          : "offline",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<ChatBloc>().add(DisconnectEvent());
                meCtrl.clear();
                toCtrl.clear();
              },
            ),
          ],
        ),

        /* ---------------- BODY ---------------- */
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (!_isConnected) {
              return _buildLogin(state);
            }

            return Column(
              children: [
                _buildContactSelector(),

                /* ---- typing banner ---- */
                if (state.typingUser == state.currentContact)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      "${state.typingUser} is typing...",
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                _buildMessages(state),
                _buildInput(),
              ],
            );
          },
        ),
      ),
    );
  }

  /* ---------------- LOGIN ---------------- */
  Widget _buildLogin(ChatState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: meCtrl,
              decoration: const InputDecoration(labelText: "Your User ID"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(ConnectEvent(meCtrl.text));
              },
              child: const Text("CONNECT"),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- CONTACT SELECT ---------------- */
  Widget _buildContactSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: toCtrl,
        decoration: const InputDecoration(
          hintText: "Enter contact ID",
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  /* ---------------- MESSAGES ---------------- */
  Widget _buildMessages(ChatState state) {
    final list = state.messages[state.currentContact] ?? [];

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final m = list[i];
          final isMe = m.sender == _currentUserId;

          // ✅ SEND READ ONLY ONCE
          if (!isMe && m.status == MessageStatus.delivered) {
            context.read<ChatBloc>().sendRead(
              messageId: m.id,
              senderId: m.sender,
            );
          }

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? Colors.green[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(m.message),
                  const SizedBox(height: 4),
                  if (isMe) _statusIcon(m.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 12);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error, size: 12, color: Colors.red);
    }
  }

  /* ---------------- INPUT ---------------- */
  Widget _buildInput() {
    if (toCtrl.text.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgCtrl,
              focusNode: _messageFocusNode,
              decoration: const InputDecoration(
                hintText: "Type a message",
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
