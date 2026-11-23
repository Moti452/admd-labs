import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/todo.dart';
import '../todo_repository.dart';
import 'todo_state.dart';

// task 1, inlocuit de TodoBloc in main
class TodoCubit extends Cubit<TodoState> {
  TodoCubit(this._repo) : super(const TodoState());
  final TodoRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      emit(TodoState(todos: await _repo.fetchTodos()));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  void add(String title) {
    final nextId = state.todos.fold(0, (m, t) => max(m, t.id)) + 1;
    final todo = Todo(userId: 1, id: nextId, title: title, completed: false);
    emit(state.copyWith(todos: [todo, ...state.todos]));
  }

  void toggle(int id) => emit(state.copyWith(todos: [
        for (final t in state.todos)
          if (t.id == id) t.copyWith(completed: !t.completed) else t,
      ]));

  void remove(int id) =>
      emit(state.copyWith(todos: state.todos.where((t) => t.id != id).toList()));
}
