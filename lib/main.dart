import 'package:flutter/material.dart';

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW04',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: const PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _addPlan(String name, String description, DateTime date) {
    setState(() => plans.add(Plan(name: name, description: description, date: date)));
  }

  void _updatePlan(int index, String name, String description) {
    setState(() {
      plans[index].name = name;
      plans[index].description = description;
    });
  }

  void _toggleCompletion(int index) {
    setState(() => plans[index].isCompleted = !plans[index].isCompleted);
  }

  void _removePlan(int index) {
    setState(() => plans.removeAt(index));
  }

  void _showPlanDialog({int? index}) {
    final nameController = TextEditingController(text: index == null ? '' : plans[index].name);
    final descriptionController = TextEditingController(text: index == null ? '' : plans[index].description);
    DateTime selectedDate = index == null ? DateTime.now() : plans[index].date;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.purple.shade50,
              title: Text(index == null ? 'Create New Plan' : 'Edit Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Plan Name')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Plan Description')),
                  ListTile(
                    title: const Text('Select Date'),
                    trailing: Text('${selectedDate.toLocal()}'.split(' ')[0]),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (index == null) {
                      _addPlan(nameController.text, descriptionController.text, selectedDate);
                    } else {
                      _updatePlan(index, nameController.text, descriptionController.text);
                    }
                  },
                  child: Text(index == null ? 'Create Plan' : 'Save Changes'),
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CW04'), backgroundColor: Colors.purple.shade300),
      body: plans.isEmpty
          ? const Center(child: Text('No Plans Added', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                Plan plan = plans[index];
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! < 0 && !plan.isCompleted) _toggleCompletion(index);
                    if (details.primaryDelta! > 0 && plan.isCompleted) _toggleCompletion(index);
                  },
                  onLongPress: () => _showPlanDialog(index: index),
                  onDoubleTap: () => _removePlan(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: plan.isCompleted ? Colors.green.shade100 : Colors.white,
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                      subtitle: Text('${plan.description}\n${plan.date.toLocal()}'.split(' ')[0], style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        tooltip: 'Create Plan',
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple.shade300,
      ),
    );
  }
}