import '../../models/todo.dart';

sealed class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  AddTodo(this.title);
  final String title;
}

class ToggleTodo extends TodoEvent {
  ToggleTodo(this.id);
  final int id;
}

class RemoveTodo extends TodoEvent {
  RemoveTodo(this.id);
  final int id;
}

// pt undo din snackbar
class RestoreTodo extends TodoEvent {
  RestoreTodo(this.todo, this.index);
  final Todo todo;
  final int index;
}
