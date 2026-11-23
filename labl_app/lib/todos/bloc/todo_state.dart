import 'package:equatable/equatable.dart';

import '../../models/todo.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final bool loading;
  final String? error;

  const TodoState({this.todos = const [], this.loading = false, this.error});

  // error nu se pastreaza, dispare la urmatorul state
  TodoState copyWith({List<Todo>? todos, bool? loading, String? error}) =>
      TodoState(
        todos: todos ?? this.todos,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [todos, loading, error];
}
