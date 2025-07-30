import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalDetailsPage extends StatefulWidget {
  final String quarterId;
  final String goalId;
  final Map<String, dynamic> goalData;

  const GoalDetailsPage({
    Key? key,
    required this.quarterId,
    required this.goalId,
    required this.goalData,
  }) : super(key: key);

  @override
  _GoalDetailsPageState createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends State<GoalDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _krController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalData['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditGoalDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.goalData['description'] ?? 'No description',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'Key Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('quarters')
                  .doc(widget.quarterId)
                  .collection('goals')
                  .doc(widget.goalId)
                  .collection('keyResults')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return Column(
                  children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['description']),
                      trailing: Checkbox(
                        value: data['completed'] ?? false,
                        onChanged: (value) async {
                          await _firestore
                              .collection('quarters')
                              .doc(widget.quarterId)
                              .collection('goals')
                              .doc(widget.goalId)
                              .collection('keyResults')
                              .doc(doc.id)
                              .update({'completed': value});

                          // Update overall progress
                          _updateGoalProgress();
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _krController,
                    decoration: const InputDecoration(
                      labelText: 'Add Key Result',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (_krController.text.isNotEmpty) {
                      await _firestore
                          .collection('quarters')
                          .doc(widget.quarterId)
                          .collection('goals')
                          .doc(widget.goalId)
                          .collection('keyResults')
                          .add({
                        'description': _krController.text,
                        'completed': false,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      _krController.clear();

                      // Update overall progress
                      _updateGoalProgress();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (widget.goalData['progress'] ?? 0) / 100,
              minHeight: 10,
            ),
            Center(
              child: Text('${widget.goalData['progress'] ?? 0}% Complete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateGoalProgress() async {
    // Calculate progress based on completed key results
    final keyResults = await _firestore
        .collection('quarters')
        .doc(widget.quarterId)
        .collection('goals')
        .doc(widget.goalId)
        .collection('keyResults')
        .get();

    if (keyResults.docs.isEmpty) {
      await _firestore
          .collection('quarters')
          .doc(widget.quarterId)
          .collection('goals')
          .doc(widget.goalId)
          .update({'progress': 0});
      return;
    }

    int completed = 0;
    for (var doc in keyResults.docs) {
      if (doc['completed'] == true) {
        completed++;
      }
    }

    int progress = ((completed / keyResults.docs.length) * 100).round();

    await _firestore
        .collection('quarters')
        .doc(widget.quarterId)
        .collection('goals')
        .doc(widget.goalId)
        .update({'progress': progress});
  }

  void _showEditGoalDialog(BuildContext context) {
    final TextEditingController titleController =
    TextEditingController(text: widget.goalData['title']);
    final TextEditingController descController =
    TextEditingController(text: widget.goalData['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Goal'),
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
                await _firestore
                    .collection('quarters')
                    .doc(widget.quarterId)
                    .collection('goals')
                    .doc(widget.goalId)
                    .update({
                  'title': titleController.text,
                  'description': descController.text,
                });
                Navigator.pop(context);
                setState(() {
                  widget.goalData['title'] = titleController.text;
                  widget.goalData['description'] = descController.text;
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}