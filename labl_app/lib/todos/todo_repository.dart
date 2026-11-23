import 'dart:math';

import 'package:dio/dio.dart';

import '../models/todo.dart';

// singura clasa care foloseste dio
class TodoRepository {
  TodoRepository(this._dio);
  final Dio _dio;
  static const _url = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<Todo>> fetchTodos() => _withRetry(() async {
        final res = await _dio.get(_url);
        return (res.data as List)
            .map((json) => Todo.fromJson(json as Map<String, dynamic>))
            .toList();
      });
}

final _random = Random();

// retry din lab 4: 5 incercari, backoff exponential + jitter
Future<T> _withRetry<T>(Future<T> Function() op, {int maxAttempts = 5}) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await op();
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
      final backoff = 400 * (1 << (attempt - 1));
      await Future<void>.delayed(
        Duration(milliseconds: backoff + _random.nextInt(backoff)),
      );
    }
  }
}
