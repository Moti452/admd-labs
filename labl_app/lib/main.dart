import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/todo_screen.dart';
import 'todos/bloc/todo_bloc.dart';
import 'todos/todo_repository.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => TodoBloc(TodoRepository(Dio()))..add(LoadTodos()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 5 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}
