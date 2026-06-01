enum MessageStatus { normal, loading, error, recipes, allergyWarning }

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

  // Konversi ke JSON untuk disimpan ke shared_preferences
  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'status': status.name,
        'recipes': recipes,
      };

  // Buat ChatMessage dari JSON yang tersimpan
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final status = MessageStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => MessageStatus.normal,
    );

    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      status: status,
      recipes: json['recipes'] != null ? List.from(json['recipes']) : null,
    );
  }
}
