import 'package:flutter/material.dart';

class Todo {
  final String id;
  String title;
  bool done;

  Todo({
    required this.id,
    required this.title,
    this.done = false,
  });
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _items = [
    Todo(id: '1', title: 'Aprende Flutter Layouts'),
    Todo(id: '2', title: 'Rezolvă Lab 3'),
  ];

/*
bug 1
int _countCompleted() {
  int count = 0;
  for (var i = 0; i <= _items.length; i++) { // Bug-ul este <= în loc de <
    if (_items[i].done) count++;
  }
  return count;
}*/


/*bug 3 
String? _filter; 
List<Todo> get _filteredItems {
  return _items.where((t) => t.title.contains(_filter!)).toList();
}*/




    int _countCompleted() {
    int count = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].done) count++;
    }
    return count;
  }

  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      _items.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _inputController.text.trim(),
        ),
      );
    });
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

 void _toggleTodo(Todo todo) {
  setState(() {
    todo.done = !todo.done;/*pt bug 2 scoatem setstate*/  
  });
}

  void _removeTodo(int index, Todo todo) {
    setState(() {
      _items.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sarcina "${todo.title}" a fost ștersă'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, todo);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List (${_countCompleted()})'),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Nu există sarcini.'))
          : ListView.builder(
              itemCount: _items.length,  //pt bug 3 devine itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final todo = _items[index];  //pt bug 3 devine final todo = _filteredItems[index];
                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeTodo(index, todo),
                  child: TodoTile(
                    todo: todo,
                    onChanged: () => _toggleTodo(todo),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
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
          value: todo.done,
          onChanged: (_) => onChanged(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}