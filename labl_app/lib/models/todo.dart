import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// Fișierul acesta este generat de build_runner:
//   dart run build_runner build
part 'todo.g.dart';

@JsonSerializable()
class Todo extends Equatable {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  const Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  /// Câmpurile sunt final, deci la bifare creăm o copie modificată.
  Todo copyWith({int? userId, int? id, String? title, bool? completed}) {
    return Todo(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  /// Equatable compară două Todo-uri după aceste câmpuri.
  @override
  List<Object?> get props => [userId, id, title, completed];
}