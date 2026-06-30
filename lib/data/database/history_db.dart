import 'package:hive/hive.dart';

class HistoryEvent {
  final String id;
  final String taskId;
  final String title;
  final String subtitle;
  final String actionType;
  final DateTime occurredAt;

  HistoryEvent({
    required this.id,
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.actionType,
    required this.occurredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'subtitle': subtitle,
      'actionType': actionType,
      'occurredAt': occurredAt.toIso8601String(),
    };
  }

  factory HistoryEvent.fromMap(Map data) {
    return HistoryEvent(
      id: data['id'],
      taskId: data['taskId'],
      title: data['title'],
      subtitle: data['subtitle'],
      actionType: data['actionType'],
      occurredAt: DateTime.parse(data['occurredAt']),
    );
  }
}

class HistoryDB {
  final Box box = Hive.box('history');

  void addEvent(HistoryEvent event) {
    box.put(event.id, event.toMap());
  }

  List<HistoryEvent> getEvents() {
    return box.values.map((e) => HistoryEvent.fromMap(Map.from(e))).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  void clearHistory() {
    box.clear();
  }
}
