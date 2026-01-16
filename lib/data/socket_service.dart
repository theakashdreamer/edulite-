import 'dart:convert';
import 'dart:developer' as dev;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  IOWebSocketChannel? _channel;
  bool _connected = false;

  final String _serverUrl = 'ws://192.168.29.155:5000';

  /* ---------------- CONNECT ---------------- */
  void connect(String userId) {
    if (_connected) return;

    dev.log("🔌 Connecting WS", name: "SocketService");

    _channel = IOWebSocketChannel.connect(_serverUrl);

    _connected = true;

    // Register AFTER connect
    _channel!.sink.add(jsonEncode({
      "type": "register",
      "userId": userId,
    }));
  }

  /* ---------------- SEND MESSAGE ---------------- */
  void sendMessage(String sender, String receiver, String message) {
    if (!_connected || _channel == null) {
      dev.log("❌ WS not connected", name: "SocketService");
      return;
    }

    if (message.trim().isEmpty) {
      dev.log("⚠️ Empty message blocked", name: "SocketService");
      return;
    }

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final payload = {
      "type": "privateMessage",
      "messageId": messageId,
      "senderId": sender,
      "receiverId": receiver,
      "message": message,
    };

    dev.log("📤 SEND $payload", name: "SocketService");
    _channel!.sink.add(jsonEncode(payload));
  }

  /* ---------------- LISTEN ---------------- */
  Stream<Map<String, dynamic>> get messageStream {
    if (_channel == null) {
      return const Stream.empty();
    }

    return _channel!.stream.map((data) {
      dev.log("📩 RAW $data", name: "SocketService");
      return jsonDecode(data as String);
    });
  }

  /* ---------------- DISCONNECT ---------------- */
  void disconnect() {
    dev.log("🔌 Disconnect WS", name: "SocketService");
    _connected = false;
    _channel?.sink.close();
    _channel = null;
  }
}
