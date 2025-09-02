part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.threadId,
    required this.resourceId,
    required this.messages,
    required this.isLoading,
    required this.error,
  });

  factory ChatState.initial() => ChatState(
        threadId: const Uuid().v4(),
        resourceId: const Uuid().v4(),
        messages: const [],
        isLoading: false,
        error: null,
      );
  final String threadId;
  final String resourceId;
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  ChatState copyWith({
    String? threadId,
    String? resourceId,
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        threadId: threadId ?? this.threadId,
        resourceId: resourceId ?? this.resourceId,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [
        threadId,
        resourceId,
        messages,
        isLoading,
        error,
      ];
}
