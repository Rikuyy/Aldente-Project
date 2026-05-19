class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String message;
  final String time;
  final String date;
  bool isRead;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.isRead,
    this.actionUrl,
  });
}

enum NotifType { recipe, shopping, budget, tip }

class InventoryCategory {
  final String name;
  final String icon;
  final List<String> items;

  InventoryCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}

class DailyExpense {
  final String day;
  final double amount;
  DailyExpense(this.day, this.amount);
}

class TodoItem {
  final String title;
  final String subtitle;
  final bool isDone;
  TodoItem({required this.title, required this.subtitle, this.isDone = false});
}
