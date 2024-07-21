import 'package:intl/intl.dart';

class Task {
  String description; // Task description
  String who; // Person assigned to the task
  String when; // Due date of the task in 'yyyy-MM-dd' format
  bool isComplete; // Status indicating if the task is completed
  final String event; // The ID of the event this task belongs to

  // Constructor
  Task({
    required this.description,
    required this.who,
    required this.when,
    this.isComplete = false, // Default value for completion status
    required this.event,
  });

  // Converts the Task object to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'who': who,
      'when': when,
      'isComplete': isComplete,
      'event': event,
    };
  }

  // Creates a Task object from a map retrieved from Firestore
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      description: map['description'],
      who: map['who'],
      when: map['when'],
      isComplete: map['isComplete'] ?? false, // Default to false if not present
      event: map['event'],
    );
  }

  // Creates a copy of the Task object with optional new values
  Task copyWith({
    String? description,
    String? who,
    String? when,
    bool? isComplete,
    String? event,
  }) {
    return Task(
      description: description ?? this.description,
      who: who ?? this.who,
      when: when ?? this.when,
      isComplete: isComplete ?? this.isComplete,
      event: event ?? this.event,
    );
  }

  @override
  String toString() {
    return 'Task(description: $description, who: $who, when: $when, isComplete: $isComplete, event: $event)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
      other.description == description &&
      other.who == who &&
      other.when == when &&
      other.isComplete == isComplete &&
      other.event == event;
  }

  @override
  int get hashCode {
    return description.hashCode ^
      who.hashCode ^
      when.hashCode ^
      isComplete.hashCode ^
      event.hashCode;
  }

  // Parses the 'when' field into a DateTime object
  DateTime? get dueDate {
    try {
      return DateFormat('yyyy-MM-dd').parse(when);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // Formats the due date into a human-readable string
  String get formattedDueDate {
    final date = dueDate;
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : 'No Due Date';
  }
}
