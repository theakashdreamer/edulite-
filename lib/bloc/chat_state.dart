import 'package:equatable/equatable.dart';
import '../models/chat_model.dart';

enum ConnectionStatus {
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class ChatState extends Equatable {
  final ConnectionStatus connectionStatus;
  final String? userId;

  final Map<String, List<ChatMessage>> messages;

  /// userId → online
  final Map<String, bool> presence;

  /// typing userId
  final String? typingUser;

  final String? currentContact;
  final String? error;

  const ChatState({
    this.connectionStatus = ConnectionStatus.disconnected,
    this.userId,
    this.messages = const {},
    this.presence = const {},
    this.typingUser,
    this.currentContact,
    this.error,
  });

  bool isOnline(String userId) => presence[userId] == true;

  ChatState copyWith({
    ConnectionStatus? connectionStatus,
    String? userId,
    Map<String, List<ChatMessage>>? messages,
    Map<String, bool>? presence,
    String? typingUser,
    String? currentContact,
    String? error,
  }) {
    return ChatState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      presence: presence ?? this.presence,
      typingUser: typingUser,
      currentContact: currentContact ?? this.currentContact,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [connectionStatus, userId, messages, presence, typingUser, currentContact, error];
}


