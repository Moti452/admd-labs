import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labl_app/models/todo.dart';
import 'package:labl_app/todos/bloc/todo_bloc.dart';
import 'package:labl_app/todos/todo_repository.dart';
import 'package:mocktail/mocktail.dart';

// fake, testul nu ajunge la api
class FakeTodoRepository extends Mock implements TodoRepository {}

void main() {
  final repo = FakeTodoRepository();

  blocTest<TodoBloc, TodoState>(
    'add then toggle emits two states in order',
    build: () => TodoBloc(repo),
    act: (bloc) => bloc
      ..add(AddTodo('Milk'))
      ..add(ToggleTodo(1)),
    expect: () => [
      const TodoState(todos: [
        Todo(userId: 1, id: 1, title: 'Milk', completed: false),
      ]),
      const TodoState(todos: [
        Todo(userId: 1, id: 1, title: 'Milk', completed: true),
      ]),
    ],
  );

  test('two states with the same todos compare equal', () {
    const json = {'userId': 1, 'id': 1, 'title': 'Milk', 'completed': false};
    final a = TodoState(todos: [Todo.fromJson(json)]);
    final b = TodoState(todos: [Todo.fromJson(json)]);
    expect(identical(a, b), isFalse);
    expect(a, b);
  });
}
