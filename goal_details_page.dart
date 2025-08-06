import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalData['title'] ?? 'Goal Details'),
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
            // Goal Description
            Text(
              widget.goalData['description'] ?? 'No description available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Key Results Section
            const Text(
              'Key Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Key Results List
            _buildKeyResultsList(),
            const SizedBox(height: 20),

            // Add Key Result Input
            _buildAddKeyResultField(),
            const SizedBox(height: 20),

            // Progress Indicator
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyResultsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('quarters')
          .doc(widget.quarterId)
          .collection('goals')
          .doc(widget.goalId)
          .collection('keyResults')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No key results added yet'),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['description'] ?? 'No description'),
              trailing: Checkbox(
                value: data['completed'] ?? false,
                onChanged: (value) => _updateKeyResultStatus(doc.id, value),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAddKeyResultField() {
    return Row(
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
          onPressed: _addKeyResult,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (widget.goalData['progress'] ?? 0) / 100,
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.goalData['progress'] ?? 0}% Complete',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> _addKeyResult() async {
    if (_krController.text.isEmpty) return;

    try {
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
        'userId': _currentUser?.uid,
      });

      _krController.clear();
      await _updateGoalProgress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add key result: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateKeyResultStatus(String docId, bool? value) async {
    if (value == null) return;

    try {
      await _firestore
          .collection('quarters')
          .doc(widget.quarterId)
          .collection('goals')
          .doc(widget.goalId)
          .collection('keyResults')
          .doc(docId)
          .update({'completed': value});

      await _updateGoalProgress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateGoalProgress() async {
    try {
      final keyResults = await _firestore
          .collection('quarters')
          .doc(widget.quarterId)
          .collection('goals')
          .doc(widget.goalId)
          .collection('keyResults')
          .get();

      final total = keyResults.docs.length;
      if (total == 0) {
        await _updateProgressValue(0);
        return;
      }

      final completed = keyResults.docs.where((doc) => doc['completed'] == true).length;
      final progress = ((completed / total) * 100).round();

      await _updateProgressValue(progress);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateProgressValue(int progress) async {
    await _firestore
        .collection('quarters')
        .doc(widget.quarterId)
        .collection('goals')
        .doc(widget.goalId)
        .update({'progress': progress});

    setState(() {
      widget.goalData['progress'] = progress;
    });
  }

  void _showEditGoalDialog(BuildContext context) {
    final titleController = TextEditingController(text: widget.goalData['title']);
    final descController = TextEditingController(text: widget.goalData['description']);

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
              const SizedBox(height: 10),
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
              onPressed: () => _saveGoalChanges(context, titleController, descController),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveGoalChanges(
      BuildContext context,
      TextEditingController titleController,
      TextEditingController descController,
      ) async {
    try {
      await _firestore
          .collection('quarters')
          .doc(widget.quarterId)
          .collection('goals')
          .doc(widget.goalId)
          .update({
        'title': titleController.text,
        'description': descController.text,
      });

      setState(() {
        widget.goalData['title'] = titleController.text;
        widget.goalData['description'] = descController.text;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update goal: ${e.toString()}')),
      );
    }
  }
}