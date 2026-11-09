import 'dart:math';

import 'package:dio/dio.dart';

import '../models/todo.dart';

typedef RetryLogger = void Function(String message);

class TodoApi {
  TodoApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  /// GET /todos (sau alt path, ex. '/nope' pentru testul de retry).
  /// JSON-ul este decodat doar aici.
  Future<List<Todo>> fetchTodos({String path = '/todos'}) async {
    final res = await _dio.get(path);
    final raw = res.data as List<dynamic>;
    return raw
        .map((j) => Todo.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

final Random _random = Random();

/// Rulează [op] de maxim [maxAttempts] ori.
/// Între încercări așteaptă: backoff exponențial (400, 800, 1600, 3200 ms)
/// + jitter aleator între 0 și backoff, ca retry-urile să nu se alinieze.
Future<T> withRetry<T>(
  Future<T> Function() op, {
  int maxAttempts = 5,
  int baseDelayMs = 400,
  RetryLogger? log,
}) async {
  for (var attempt = 1;; attempt++) {
    try {
      final result = await op();
      log?.call('Încercarea $attempt/$maxAttempts: OK');
      return result;
    } catch (e) {
      final reason = _describeError(e);
      if (attempt >= maxAttempts) {
        log?.call(
          'Încercarea $attempt/$maxAttempts: eșuat ($reason). Renunț.',
        );
        rethrow;
      }
      final backoff = baseDelayMs * (1 << (attempt - 1));
      final jitter = _random.nextInt(backoff);
      final delay = backoff + jitter;
      log?.call(
        'Încercarea $attempt/$maxAttempts: eșuat ($reason). '
        'Reîncerc în $delay ms (backoff $backoff + jitter $jitter)',
      );
      await Future<void>.delayed(Duration(milliseconds: delay));
    }
  }
}

String _describeError(Object e) {
  if (e is DioException) {
    final status = e.response?.statusCode;
    return status != null ? 'HTTP $status' : e.type.name;
  }
  return e.runtimeType.toString();
}