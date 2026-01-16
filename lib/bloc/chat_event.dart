import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}
/* ---------------- CHAT LIST ---------------- */
class LoadChatListEvent extends ChatEvent {}

/* CONNECTION */
class ConnectEvent extends ChatEvent {
  final String userId;
  const ConnectEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DisconnectEvent extends ChatEvent {}

/* MESSAGES */
class SendMessageEvent extends ChatEvent {
  final String sender;
  final String receiver;
  final String message;

  const SendMessageEvent({
    required this.sender,
    required this.receiver,
    required this.message,
  });

  @override
  List<Object?> get props => [sender, receiver, message];
}

class MessageReceivedEvent extends ChatEvent {
  final Map<String, dynamic> data;
  const MessageReceivedEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class ClearChatEvent extends ChatEvent {
  final String? contactId;
  const ClearChatEvent({this.contactId});

  @override
  List<Object?> get props => [contactId];
}
