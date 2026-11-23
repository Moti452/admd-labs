import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/todo.dart';
import '../todos/bloc/todo_bloc.dart';

// fara setState, ecranul doar citeste state-ul din TodoBloc
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final title = _inputController.text.trim();
    if (title.isEmpty) return;
    context.read<TodoBloc>().add(AddTodo(title));
    _inputController.clear();
    Navigator.of(context).pop();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adaugă o sarcină nouă'),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Titlu sarcină...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
  }

  void _removeTodo(Todo todo, int index) {
    final bloc = context.read<TodoBloc>();
    bloc.add(RemoveTodo(todo.id));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sarcina "${todo.title}" a fost ștersă'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => bloc.add(RestoreTodo(todo, index)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final done = state.todos.where((t) => t.completed).length;
        return Scaffold(
          appBar: AppBar(
            title: Text('Todo ($done/${state.todos.length})'),
            actions: [
              IconButton(
                tooltip: 'Reîncarcă de la API',
                icon: const Icon(Icons.refresh),
                onPressed: state.loading
                    ? null
                    : () => context.read<TodoBloc>().add(LoadTodos()),
              ),
            ],
          ),
          body: _buildBody(state),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(TodoState state) {
    if (state.loading && state.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<TodoBloc>().add(LoadTodos()),
              child: const Text('Reîncearcă'),
            ),
          ],
        ),
      );
    }
    if (state.todos.isEmpty) {
      return const Center(child: Text('Nu există sarcini.'));
    }
    return ListView.builder(
      itemCount: state.todos.length,
      itemBuilder: (context, index) {
        final todo = state.todos[index];
        return Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _removeTodo(todo, index),
          child: TodoTile(
            todo: todo,
            onChanged: () => context.read<TodoBloc>().add(ToggleTodo(todo.id)),
          ),
        );
      },
    );
  }
}

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onChanged;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) => onChanged(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('id ${todo.id} · user ${todo.userId}'),
      ),
    );
  }
}
