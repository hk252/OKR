import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goal_details_page.dart';

class QuarterGoalsPage extends StatefulWidget {
  final String quarterId;
  final String quarterName;

  const QuarterGoalsPage({Key? key, required this.quarterId, required this.quarterName}) : super(key: key);

  @override
  _QuarterGoalsPageState createState() => _QuarterGoalsPageState();
}

class _QuarterGoalsPageState extends State<QuarterGoalsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quarterName} Goals'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quarters')
            .doc(widget.quarterId)
            .collection('goals')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  Text('An error happens getting data'),
                  Text('${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No goals added for ${widget.quarterName}'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Text('Progress: ${(data['progress'] ?? 0).toString()}%'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalDetailsPage(
                          quarterId: widget.quarterId,
                          goalId: document.id,
                          goalData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add New Goal',
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Goal Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await _firestore
                      .collection('quarters')
                      .doc(widget.quarterId)
                      .collection('goals')
                      .add({
                    'title': titleController.text,
                    'description': descController.text,
                    'progress': 0,
                    'createdAt': FieldValue.serverTimestamp(),
                    'keyResults': [],
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}