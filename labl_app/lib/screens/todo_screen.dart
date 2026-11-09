import 'package:flutter/material.dart';

import '../api/todo_api.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TodoApi _api = TodoApi();
  final TextEditingController _inputController = TextEditingController();

  List<Todo> _items = [];
  final List<String> _log = [];
  bool _loading = false;
  bool _testingRetry = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _equalityCheck();
    _loadTodos();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // ---------------- Task I: equality ----------------

  void _equalityCheck() {
    const json = {
      'userId': 1,
      'id': 1,
      'title': 'delectus aut autem',
      'completed': false,
    };
    // Două instanțe separate, create din același JSON.
    final a = Todo.fromJson(json);
    final b = Todo.fromJson(json);
    debugPrint('a == b -> ${a == b}');
    debugPrint('identical(a, b) -> ${identical(a, b)}');
    debugPrint('a.toJson() -> ${a.toJson()}');
    _log.add('${_time()}  Equatable: a == b -> ${a == b}, '
        'identical(a, b) -> ${identical(a, b)}');
  }

  // ---------------- Task II: API + retry ----------------

  void _addLog(String message) {
    final line = '${_time()}  $message';
    debugPrint(line);
    if (!mounted) return;
    setState(() {
      _log.add(line);
      if (_log.length > 200) _log.removeAt(0);
    });
  }

  Future<void> _loadTodos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _addLog('GET /todos');
    try {
      final todos = await withRetry(() => _api.fetchTodos(), log: _addLog);
      if (!mounted) return;
      setState(() {
        _items = todos;
        _loading = false;
      });
      _addLog('Am primit ${todos.length} todo-uri de la API');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Nu am putut încărca lista de la API.';
      });
    }
  }

  /// Demo: path invalid -> 404 la fiecare încercare -> retry cu delay crescător.
  Future<void> _testInvalidPath() async {
    setState(() => _testingRetry = true);
    _addLog('GET /nope (test retry)');
    try {
      await withRetry(() => _api.fetchTodos(path: '/nope'), log: _addLog);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('/nope a eșuat după 5 încercări')),
      );
    } finally {
      if (mounted) setState(() => _testingRetry = false);
    }
  }

  // ---------------- Lab 3: todo list ----------------

  int _countCompleted() {
    int count = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].completed) count++;
    }
    return count;
  }

  void _addTodo() {
    final title = _inputController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _items.insert(
        0,
        Todo(
          userId: 1,
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          completed: false,
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
      final i = _items.indexWhere((t) => t.id == todo.id);
      if (i != -1) _items[i] = todo.copyWith(completed: !todo.completed);
    });
  }

  void _removeTodo(Todo todo) {
    final index = _items.indexWhere((t) => t.id == todo.id);
    setState(() {
      _items.removeWhere((t) => t.id == todo.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sarcina "${todo.title}" a fost ștersă'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index.clamp(0, _items.length), todo);
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
        title: Text('Todo (${_countCompleted()}/${_items.length})'),
        actions: [
          IconButton(
            tooltip: 'Reîncarcă de la API',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadTodos,
          ),
          IconButton(
            tooltip: 'Test retry pe /nope',
            icon: const Icon(Icons.bug_report),
            onPressed: _testingRetry ? null : _testInvalidPath,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildList()),
          RetryLogPanel(
            lines: _log,
            onClear: () => setState(_log.clear),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadTodos,
              child: const Text('Reîncearcă'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Nu există sarcini.'));
    }
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final todo = _items[index];
        return Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _removeTodo(todo),
          child: TodoTile(
            todo: todo,
            onChanged: () => _toggleTodo(todo),
          ),
        );
      },
    );
  }

  static String _time() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}.$ms';
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

/// Panoul de jos cu log-ul de retry (cerut la prezentare).
class RetryLogPanel extends StatelessWidget {
  final List<String> lines;
  final VoidCallback onClear;

  const RetryLogPanel({super.key, required this.lines, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'Retry log',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // cele mai noi linii jos
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: lines.length,
              itemBuilder: (context, i) => Text(
                lines[lines.length - 1 - i],
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}