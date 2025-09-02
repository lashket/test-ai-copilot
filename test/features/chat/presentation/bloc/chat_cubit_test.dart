import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_task_oncom/features/chat/domain/entities/message.dart';
import 'package:test_task_oncom/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:test_task_oncom/features/chat/presentation/bloc/chat_cubit.dart';

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  group('ChatCubit', () {
    late ChatCubit chatCubit;
    late MockSendMessageUseCase mockSendMessageUseCase;

    setUp(() {
      mockSendMessageUseCase = MockSendMessageUseCase();
      chatCubit = ChatCubit(mockSendMessageUseCase);
    });

    tearDown(() {
      chatCubit.close();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        // Assert
        expect(chatCubit.state.messages, isEmpty);
        expect(chatCubit.state.isLoading, isFalse);
        expect(chatCubit.state.error, isNull);
        expect(chatCubit.state.threadId, isNotEmpty);
        expect(chatCubit.state.resourceId, isNotEmpty);
      });
    });

    group('sendUserMessage', () {
      const userText = 'Hello, how are you?';
      const assistantReply = 'I am doing well, thank you!';

      blocTest<ChatCubit, ChatState>(
        'should emit loading state and then success state when message is '
        'sent successfully',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => assistantReply);
          return chatCubit;
        },
        act: (cubit) => cubit.sendUserMessage(userText),
        expect: () => [
          // First emission: user message added, loading started
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages length', 1)
              .having(
                (s) => s.messages.first.content,
                'first message content',
                userText,
              )
              .having(
                (s) => s.messages.first.role,
                'first message role',
                MessageRole.user,
              )
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.error, 'error', isNull),
          // Second emission: assistant message added, loading finished
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages length', 2)
              .having(
                (s) => s.messages.last.content,
                'last message content',
                assistantReply,
              )
              .having(
                (s) => s.messages.last.role,
                'last message role',
                MessageRole.assistant,
              )
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', isNull),
        ],
        verify: (_) {
          verify(
            () => mockSendMessageUseCase(
              userText: userText,
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).called(1);
        },
      );

      blocTest<ChatCubit, ChatState>(
        'should not send message when text is empty',
        build: () => chatCubit,
        act: (cubit) => cubit.sendUserMessage(''),
        expect: () => <ChatState>[],
        verify: (_) {
          verifyNever(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          );
        },
      );

      blocTest<ChatCubit, ChatState>(
        'should not send message when text is only whitespace',
        build: () => chatCubit,
        act: (cubit) => cubit.sendUserMessage('   \t\n  '),
        expect: () => <ChatState>[],
        verify: (_) {
          verifyNever(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          );
        },
      );

      blocTest<ChatCubit, ChatState>(
        'should trim whitespace from user message',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => assistantReply);
          return chatCubit;
        },
        act: (cubit) => cubit.sendUserMessage('  Hello  '),
        expect: () => [
          isA<ChatState>()
              .having(
                (s) => s.messages.first.content,
                'first message content',
                'Hello',
              )
              .having((s) => s.isLoading, 'isLoading', true),
          isA<ChatState>().having((s) => s.isLoading, 'isLoading', false),
        ],
        verify: (_) {
          verify(
            () => mockSendMessageUseCase(
              userText: 'Hello', // Should be trimmed
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).called(1);
        },
      );

      blocTest<ChatCubit, ChatState>(
        'should emit error state when use case throws exception',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenThrow(Exception('Network error'));
          return chatCubit;
        },
        act: (cubit) => cubit.sendUserMessage(userText),
        expect: () => [
          // First emission: user message added, loading started
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages length', 1)
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.error, 'error', isNull),
          // Second emission: error state
          isA<ChatState>()
              .having(
                (s) => s.messages.length,
                'messages length',
                1,
              ) // Only user message
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', 'Exception: Network error'),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'should maintain message history across multiple messages',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => assistantReply);
          return chatCubit;
        },
        act: (cubit) async {
          await cubit.sendUserMessage('First message');
          await cubit.sendUserMessage('Second message');
        },
        expect: () => [
          // First message sequence
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            1,
          ),
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            2,
          ),
          // Second message sequence
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            3,
          ),
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            4,
          ),
        ],
        verify: (_) {
          verify(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).called(2);
        },
      );
    });

    group('resetThread', () {
      blocTest<ChatCubit, ChatState>(
        'should reset to initial state',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => 'Reply');
          return chatCubit;
        },
        act: (cubit) async {
          // First add some messages
          await cubit.sendUserMessage('Test message');
          // Then reset
          cubit.resetThread();
        },
        expect: () => [
          // Messages from sendUserMessage
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            1,
          ),
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            2,
          ),
          // Reset state
          isA<ChatState>()
              .having((s) => s.messages, 'messages', isEmpty)
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', isNull),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'should generate new thread and resource IDs on reset',
        build: () => chatCubit,
        act: (cubit) => cubit.resetThread(),
        expect: () => [
          isA<ChatState>()
              .having((s) => s.threadId, 'threadId', isNotEmpty)
              .having((s) => s.resourceId, 'resourceId', isNotEmpty),
        ],
      );
    });

    group('message properties', () {
      blocTest<ChatCubit, ChatState>(
        'should generate unique IDs for messages',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => 'Reply');
          return chatCubit;
        },
        act: (cubit) => cubit.sendUserMessage('Test'),
        expect: () => [
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            1,
          ),
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            2,
          ),
        ],
        verify: (_) {
          final state = chatCubit.state;
          expect(state.messages.length, equals(2));
          expect(state.messages[0].id, isNotEmpty);
          expect(state.messages[1].id, isNotEmpty);
          expect(state.messages[0].id, isNot(equals(state.messages[1].id)));
        },
      );

      blocTest<ChatCubit, ChatState>(
        'should set correct timestamps for messages',
        build: () {
          when(
            () => mockSendMessageUseCase(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => 'Reply');
          return chatCubit;
        },
        act: (cubit) => cubit.sendUserMessage('Test'),
        expect: () => [
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            1,
          ),
          isA<ChatState>().having(
            (s) => s.messages.length,
            'messages length',
            2,
          ),
        ],
        verify: (_) {
          final state = chatCubit.state;
          expect(state.messages[0].createdAt, isA<DateTime>());
          expect(state.messages[1].createdAt, isA<DateTime>());
          expect(
            state.messages[1].createdAt.isAfter(state.messages[0].createdAt),
            isTrue,
          );
        },
      );
    });
  });
}
