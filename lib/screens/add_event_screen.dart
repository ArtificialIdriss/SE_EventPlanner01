import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_to_do_list/model/events_model.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event; // Nullable to handle both adding and editing

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Pre-fill fields if editing
      final event = widget.event!;
      nameController.text = event.name;
      descriptionController.text = event.description;
      locationController.text = event.location;
      startDateTime = event.startDateTime;
      endDateTime = event.endDateTime;
      notesController.text = event.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign the GlobalKey to the Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTextField(nameController, 'Event Name', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                }),
                buildTextField(descriptionController, 'Event Description', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                }),
                buildTextField(locationController, 'Location', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                }),
                buildDateTimePicker('Start Date & Time', startDateTime, (date) {
                  setState(() {
                    startDateTime = date;
                  });
                }, validator: (value) {
                  if (value == null) {
                    return 'Please select start date & time';
                  }
                  return null;
                }),
                buildDateTimePicker('End Date & Time', endDateTime, (date) {
                  setState(() {
                    endDateTime = date;
                  });
                }, validator: (value) {
                  if (value == null) {
                    return 'Please select end date & time';
                  }
                  return null;
                }),
                buildTextField(notesController, 'Notes'),
                SizedBox(height: 20),
                buildButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator, // Validator function for form validation
      ),
    );
  }

  Widget buildDateTimePicker(String label, DateTime dateTime, Function(DateTime) onDateTimeChanged,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Text(label),
          Spacer(),
          TextButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(dateTime),
                );
                if (time != null) {
                  onDateTimeChanged(DateTime(picked.year, picked.month,
                      picked.day, time.hour, time.minute));
                }
              }
            },
            child: Text(
                '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}'),
          ),
        ],
      ),
    );
  }

  Widget buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: custom_green,
            minimumSize: Size(170, 48),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              var event = Event(
                id: widget.event?.id ?? Uuid().v4(),
                name: nameController.text,
                description: descriptionController.text,
                location: locationController.text,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
                notes: notesController.text,
                invitees: widget.event?.invitees ?? [],
                isComplete: widget.event?.isComplete ?? false,
              );
              if (widget.event == null) {
                await Firestore_Datasource().addEvent(event);
              } else {
                await Firestore_Datasource().updateEvent(event);
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.event == null ? 'Add Event' : 'Save Changes'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(170, 48),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}