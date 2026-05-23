enum MessageStatus { sent, loading, error }

class ChatMessage {
  final String text;
  final bool isUser;
  final MessageStatus status;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.status = MessageStatus.sent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.loading() => ChatMessage(
        text: '...',
        isUser: false,
        status: MessageStatus.loading,
      );
}
