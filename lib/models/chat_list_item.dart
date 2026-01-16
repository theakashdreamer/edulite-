class ChatListItem {
  final String userId;
  final String name;
  final String mobile;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unreadCount;

  ChatListItem({
    required this.userId,
    required this.name,
    required this.mobile,
    this.lastMessage,
    this.lastTime,
    this.unreadCount = 0,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      userId: json['userId'],
      name: json['name'],
      mobile: json['mobile'],
      lastMessage: json['lastMessage'],
      lastTime: json['lastTime'] != null
          ? DateTime.parse(json['lastTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
