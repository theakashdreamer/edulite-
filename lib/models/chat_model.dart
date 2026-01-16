import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read, failed }
class ChatMessage extends Equatable {
  final String id;
  final String sender;
  final String receiver;
  final String message;
  final DateTime timestamp;
  final MessageStatus status;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.readAt,
  });

  ChatMessage copyWith({
    MessageStatus? status,
    DateTime? readAt,
  }) {
    return ChatMessage(
      id: id,
      sender: sender,
      receiver: receiver,
      message: message,
      timestamp: timestamp,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [id, status, readAt];
}


