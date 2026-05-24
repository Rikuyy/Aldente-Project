enum MessageStatus { normal, loading, error, recipes }

class ChatMessage {
  final String text;
  final bool isUser;
  final MessageStatus status;
  final List? recipes;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.status = MessageStatus.normal,
    this.recipes,
  });

  factory ChatMessage.loading() => const ChatMessage(
        text: '',
        isUser: false,
        status: MessageStatus.loading,
      );

  factory ChatMessage.recipes(List recipes) => ChatMessage(
        text: '',
        isUser: false,
        status: MessageStatus.recipes,
        recipes: recipes,
      );
}
