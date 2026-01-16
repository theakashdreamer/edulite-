import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';

import '../models/chat_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  IOWebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _typingTimer;

  final String _url = 'ws://192.168.29.155:5000';

  ChatBloc() : super(const ChatState()) {
    on<ConnectEvent>(_onConnect);
    on<SendMessageEvent>(_onSend);
    on<MessageReceivedEvent>(_onReceive);
    on<DisconnectEvent>(_onDisconnect);
    on<ClearChatEvent>(_onClearChat);
  }

  /* ---------------- CONNECT ---------------- */
  Future<void> _onConnect(ConnectEvent e, Emitter emit) async {
    emit(state.copyWith(connectionStatus: ConnectionStatus.connecting));

    _channel = IOWebSocketChannel.connect(_url);

    _sub = _channel!.stream.listen((raw) {
      add(MessageReceivedEvent(jsonDecode(raw)));
    });

    _channel!.sink.add(jsonEncode({
      "type": "register",
      "userId": e.userId,
    }));

    emit(state.copyWith(
      connectionStatus: ConnectionStatus.connected,
      userId: e.userId,
    ));
  }

  /* ---------------- SEND MESSAGE ---------------- */
  void _onSend(SendMessageEvent e, Emitter emit) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final msg = ChatMessage(
      id: id,
      sender: e.sender,
      receiver: e.receiver,
      message: e.message,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    final updated = Map<String, List<ChatMessage>>.from(state.messages);
    updated[e.receiver] = [...(updated[e.receiver] ?? []), msg];

    emit(state.copyWith(
      messages: updated,
      currentContact: e.receiver,
    ));

    _channel?.sink.add(jsonEncode({
      "type": "privateMessage",
      "messageId": id,
      "senderId": e.sender,
      "receiverId": e.receiver,
      "message": e.message,
    }));
  }

  /* ---------------- RECEIVE ---------------- */
  void _onReceive(MessageReceivedEvent e, Emitter emit) {
    final d = e.data;


    dev.log('Received socket data: $d', name: 'SOCKET');

    /* ACK */
    if (d["type"] == "ack") {
      _updateStatus(
        d["messageId"],
        d["status"] == "sent"
            ? MessageStatus.sent
            : MessageStatus.delivered,
      );
      return;
    }

    /* READ */
    if (d["type"] == "read") {
      _updateStatus(d["messageId"], MessageStatus.read);
      return;
    }

    /* PRESENCE */
    if (d["type"] == "presence") {
      final p = Map<String, bool>.from(state.presence);
      p[d["userId"]] = d["online"] == true;
      emit(state.copyWith(presence: p));
      return;
    }

    /* TYPING */
    if (d["type"] == "typing") {
      emit(state.copyWith(
        typingUser: d["isTyping"] == true ? d["from"] : null,
      ));
      return;
    }

    /* MESSAGE */
    if (d["type"] == "privateMessage") {
      final msg = ChatMessage(
        id: d["messageId"],
        sender: d["senderId"],
        receiver: d["receiverId"],
        message: d["message"],
        timestamp: DateTime.parse(d["timestamp"]),
        status: MessageStatus.delivered,
      );

      final updated = Map<String, List<ChatMessage>>.from(state.messages);
      updated[msg.sender] = [...(updated[msg.sender] ?? []), msg];

      emit(state.copyWith(messages: updated));
    }
  }

  /* ---------------- STATUS UPDATE ---------------- */
  void _updateStatus(String id, MessageStatus status) {
    final updated = Map<String, List<ChatMessage>>.from(state.messages);

    for (final key in updated.keys) {
      final index = updated[key]!.indexWhere((m) => m.id == id);
      if (index != -1) {
        updated[key]![index] =
            updated[key]![index].copyWith(status: status);
        emit(state.copyWith(messages: updated));
        return;
      }
    }
  }
  void sendRead({
    required String messageId,
    required String senderId,
  }) {
    _channel?.sink.add(jsonEncode({
      "type": "read",
      "messageId": messageId,
      "senderId": senderId,
      "readerId": state.userId,
    }));
  }

  /* ---------------- TYPING ---------------- */
  void sendTyping(String to) {
    _typingTimer?.cancel();

    _channel?.sink.add(jsonEncode({
      "type": "typing",
      "from": state.userId,
      "to": to,
      "isTyping": true,
    }));

    _typingTimer = Timer(const Duration(seconds: 2), () {
      _channel?.sink.add(jsonEncode({
        "type": "typing",
        "from": state.userId,
        "to": to,
        "isTyping": false,
      }));
    });
  }

  /* ---------------- CLEAR CHAT ---------------- */
  void _onClearChat(ClearChatEvent e, Emitter emit) {
    final updated = Map<String, List<ChatMessage>>.from(state.messages);
    if (e.contactId != null) {
      updated.remove(e.contactId);
    } else {
      updated.clear();
    }
    emit(state.copyWith(messages: updated));
  }

  /* ---------------- DISCONNECT ---------------- */
  Future<void> _onDisconnect(DisconnectEvent e, Emitter emit) async {
    await _sub?.cancel();
    await _channel?.sink.close();
    emit(const ChatState());
  }

}
