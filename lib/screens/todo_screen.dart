import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _editController.dispose();
    super.dispose();
  }

  // TODO 1: CREATE - Call TodoService.addTodo when adding new todo
  void _addTodo() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        // STUDENT: Call TodoService.addTodo here
        // Example: await TodoService.addTodo(_controller.text.trim());
        await TodoService.addTodo(text);

        _controller.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo added successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding todo: $e')),
        );
      }
    }
  }

  // TODO 2: UPDATE - Call TodoService.toggleTodo when checkbox changes
  void _toggleTodo(String id, bool currentStatus) async {
    try {
      // STUDENT: Call TodoService.toggleTodo here
      // Example: await TodoService.toggleTodo(id, currentStatus);
      await TodoService.toggleTodo(id, currentStatus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  // TODO 3: DELETE - Call TodoService.deleteTodo when deleting
  void _deleteTodo(String id) async {
    try {
      // STUDENT: Call TodoService.deleteTodo here
      // Example: await TodoService.deleteTodo(id);
      await TodoService.deleteTodo(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo deleted!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  // TODO 4: UPDATE - Call TodoService.updateTodo when editing
  void _editTodo(DocumentSnapshot todo) {
    final todoData = todo.data() as Map<String, dynamic>?;
    _editController.text = todoData?['task'] ?? '';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(hintText: 'Enter new task'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newText = _editController.text.trim();
              if (newText.isNotEmpty) {
                try {
                  // STUDENT: Call TodoService.updateTodo here
                  // Example: await TodoService.updateTodo(todo.id, _editController.text.trim());
                  await TodoService.updateTodo(todo.id, newText);

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todo updated!')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating todo: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // TODO 5: BONUS - Call TodoService.deleteCompletedTodos
  void _deleteCompletedTodos() async {
    try {
      // STUDENT: Call TodoService.deleteCompletedTodos here
      // Example: await TodoService.deleteCompletedTodos();
      await TodoService.deleteCompletedTodos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completed todos cleared!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing completed todos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _deleteCompletedTodos,
            tooltip: 'Clear Completed',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // TODO 6: READ - Use TodoService.getTodosStream for real-time data
              // STUDENT: Assign the stream from TodoService.getTodosStream()
              // Example: stream: TodoService.getTodosStream(),
              stream: TodoService.getTodosStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data!.docs;
                if (todos.isEmpty) {
                  return const Center(
                    child: Text('No todos yet! Add a new todo to get started.'),
                  );
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final todoData = todo.data() as Map<String, dynamic>?;
                    final bool isCompleted = todoData?['completed'] ?? false;
                    final String taskText = todoData?['task'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: (_) => _toggleTodo(todo.id, isCompleted),
                        ),
                        title: Text(
                          taskText,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTodo(todo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTodo(todo.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
