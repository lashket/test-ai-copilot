import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task_oncom/features/chat/domain/entities/message.dart';
import 'package:test_task_oncom/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:uuid/uuid.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._sendMessage) : super(ChatState.initial());
  final SendMessageUseCase _sendMessage;

  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = Message(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final next = <Message>[...state.messages, userMsg];
    emit(
      state.copyWith(
        messages: next,
        isLoading: true,
      ),
    );

    try {
      final replyText = await _sendMessage(
        userText: trimmed,
        threadId: state.threadId,
        resourceId: state.resourceId,
      );

      final assistantMsg = Message(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: replyText,
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          messages: [...next, assistantMsg],
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void resetThread() {
    emit(ChatState.initial());
  }
}
