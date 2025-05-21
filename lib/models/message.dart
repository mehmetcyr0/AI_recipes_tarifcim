class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  
  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
