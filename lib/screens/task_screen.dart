import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/model/events_model.dart';
import 'package:flutter_to_do_list/model/task_model.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Map<String, Event> eventsMap = {};
  String? selectedEventId;
  DateTime? selectedDueDate;
  final Firestore_Datasource _datasource = Firestore_Datasource();
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _storageFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .where('isComplete', isEqualTo: false)
            .get();

        List<Event> events = _datasource.getEventsFromSnapshot(querySnapshot);

        setState(() {
          eventsMap = {for (var event in events) event.id: event};
          if (eventsMap.isNotEmpty) {
            selectedEventId = eventsMap.keys.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> showTaskDialog({Task? task}) async {
    final isEditing = task != null;
    TextEditingController descriptionController = TextEditingController(text: task?.description ?? '');
    TextEditingController whoController = TextEditingController(text: task?.who ?? '');
    DateTime? initialDueDate = task != null ? _parseDate(task.when) : null;

    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'Add Task'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: whoController,
                  decoration: InputDecoration(labelText: 'Assigned To'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the person assigned';
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due Date:'),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDueDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        selectedDueDate == null
                            ? 'Select Date'
                            : _displayFormat.format(selectedDueDate!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  String description = descriptionController.text.trim();
                  String who = whoController.text.trim();
                  String when = selectedDueDate != null
                      ? _storageFormat.format(selectedDueDate!)
                      : (task?.when ?? '');

                  if (when.isNotEmpty) {
                    Task updatedTask = Task(
                      description: description,
                      who: who,
                      when: when,
                      event: task?.event ?? selectedEventId!,
                      isComplete: task?.isComplete ?? false,
                    );

                    if (isEditing) {
                      // Update the existing task
                      setState(() {
                        Event? event = eventsMap[selectedEventId!];
                        if (event != null) {
                          final taskIndex = event.tasks.indexWhere(
                              (t) =>
                                  t.description == task.description &&
                                  t.when == task.when);
                          if (taskIndex != -1) {
                            event.tasks[taskIndex] = updatedTask;
                            eventsMap[selectedEventId!] = event;
                          }
                        }
                      });
                      try {
                        Event? event = eventsMap[selectedEventId!];
                        if (event != null) {
                          _datasource.updateEvent(event);
                        }
                      } catch (e) {
                        print('Error updating task: $e');
                      }
                    } else {
                      // Add a new task
                      setState(() {
                        Event? event = eventsMap[selectedEventId!];
                        if (event != null) {
                          event.tasks.add(updatedTask);
                          eventsMap[selectedEventId!] = event;
                        }
                      });
                      try {
                        Event? event = eventsMap[selectedEventId!];
                        if (event != null) {
                          _datasource.updateEvent(event);
                        }
                      } catch (e) {
                        print('Error adding task: $e');
                      }
                    }

                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return _storageFormat.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  Future<void> deleteTask(Task task) async {
    if (selectedEventId == null) return;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        bool success = await _datasource.deleteTask(selectedEventId!, task);

        if (success) {
          setState(() {
            Event? event = eventsMap[selectedEventId!];
            if (event != null) {
              event.tasks.removeWhere((t) =>
                  t.description == task.description && t.when == task.when);
              eventsMap[selectedEventId!] = event;
            }
          });
        }
      } catch (e) {
        print('Error deleting task: $e');
      }
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    if (selectedEventId == null) return;

    try {
      task.isComplete = !task.isComplete;
      bool success = task.isComplete
          ? await _datasource.markTaskAsComplete(selectedEventId!, task)
          : await _datasource.updateTask(selectedEventId!, task);

      if (success) {
        setState(() {
          Event? event = eventsMap[selectedEventId!];
          if (event != null) {
            final taskIndex = event.tasks.indexWhere((t) =>
                t.description == task.description && t.when == task.when);
            if (taskIndex != -1) {
              event.tasks[taskIndex] = task;
              eventsMap[selectedEventId!] = event;
            }
          }
        });
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> incompleteTasks = [];
    List<Task> completeTasks = [];

    if (selectedEventId != null) {
      Event? event = eventsMap[selectedEventId!];
      if (event != null) {
        incompleteTasks = event.tasks.where((task) => !task.isComplete).toList();
        completeTasks = event.tasks.where((task) => task.isComplete).toList();
      }
    }

    incompleteTasks.sort((a, b) => a.when.compareTo(b.when));
    completeTasks.sort((a, b) => a.when.compareTo(b.when));

    List<Task> finalTasks = [...incompleteTasks, ...completeTasks];

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Event:'),
                SizedBox(width: 8.0),
                DropdownButton<String>(
                  value: selectedEventId,
                  onChanged: (value) {
                    setState(() {
                      selectedEventId = value;
                    });
                  },
                  items: eventsMap.keys.map((String eventId) {
                    return DropdownMenuItem<String>(
                      value: eventId,
                      child: Text(eventsMap[eventId]?.name ?? 'Unknown Event'),
                    );
                  }).toList(),
                  hint: Text('Select Event'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: selectedEventId == null
          ? Center(child: Text('No Event Selected'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Task List',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => showTaskDialog(),
                        child: Text('Add Task'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Assigned To', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Due Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: finalTasks.length,
                      itemBuilder: (context, index) {
                        final task = finalTasks[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 4, child: Text(task.description, style: TextStyle(decoration: task.isComplete ? TextDecoration.lineThrough : TextDecoration.none))),
                              Expanded(flex: 3, child: Text(task.who, textAlign: TextAlign.center)),
                              Expanded(flex: 3, child: Text(_displayFormat.format(_parseDate(task.when) ?? DateTime.now()), textAlign: TextAlign.center)), // Format date for display
                              Expanded(flex: 2, child: Text(task.isComplete ? 'Complete' : 'Incomplete', textAlign: TextAlign.center)),
                              Expanded(
                                flex: 1,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      showTaskDialog(task: task);
                                    } else if (value == 'Delete') {
                                      deleteTask(task);
                                    } else if (value == 'Complete') {
                                      toggleTaskCompletion(task);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(value: 'Edit', child: Text('Edit Task')),
                                      PopupMenuItem<String>(value: 'Delete', child: Text('Delete Task')),
                                      PopupMenuItem<String>(value: 'Complete', child: Text(task.isComplete ? 'Mark as Incomplete' : 'Mark as Complete')),
                                    ];
                                  },
                                  icon: Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 55.0), // Added whitespace at the bottom
                ],
              ),
            ),
    );
  }
}
