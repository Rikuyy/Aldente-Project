enum MessageStatus {
  sent,
  loading,
  error,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final MessageStatus status;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.loading() => ChatMessage(
        text: '',
        isUser: false,
        status: MessageStatus.loading,
      );
}
