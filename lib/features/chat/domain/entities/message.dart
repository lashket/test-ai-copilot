import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  Message copyWith({String? content}) => Message(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        role,
        content,
        createdAt,
      ];
}
