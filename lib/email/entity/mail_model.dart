class MailModel {
  final String sender;
  final String subject;
  final String time;
  final bool unread;

  MailModel({
    required this.sender,
    required this.subject,
    required this.time,
    this.unread = false,
  });
}
