import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/const/colors.dart';
import 'package:flutter_to_do_list/data/firestor.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_to_do_list/model/events_model.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextField(nameController, 'Event Name'),
              buildTextField(descriptionController, 'Event Description'),
              buildTextField(locationController, 'Location'),
              buildDateTimePicker('Start Date & Time', startDateTime, (date) {
                setState(() {
                  startDateTime = date;
                });
              }),
              buildDateTimePicker('End Date & Time', endDateTime, (date) {
                setState(() {
                  endDateTime = date;
                });
              }),
              buildTextField(notesController, 'Notes'),
              SizedBox(height: 20),
              buildButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDateTimePicker(
      String label, DateTime dateTime, Function(DateTime) onDateTimeChanged) {
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
          onPressed: () {
            var uuid = Uuid().v4();
            var event = Event(
              id: uuid,
              name: nameController.text,
              description: descriptionController.text,
              location: locationController.text,
              startDateTime: startDateTime,
              endDateTime: endDateTime,
              notes: notesController.text,
              invitees: [],
            );
            Firestore_Datasource().addEvent(event);
            Navigator.pop(context);
          },
          child: Text('Add Event'),
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
