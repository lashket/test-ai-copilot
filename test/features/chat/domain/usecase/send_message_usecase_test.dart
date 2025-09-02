import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_task_oncom/features/chat/domain/repository/chat_repository.dart';
import 'package:test_task_oncom/features/chat/domain/usecase/send_message_usecase.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('SendMessageUseCase', () {
    late SendMessageUseCase useCase;
    late MockChatRepository mockRepository;

    setUp(() {
      mockRepository = MockChatRepository();
      useCase = SendMessageUseCase(mockRepository);
    });

    group('call', () {
      test(
        'should call repository ask method with correct parameters',
        () async {
          // Arrange
          const userText = 'Hello, how are you?';
          const threadId = 'thread-123';
          const resourceId = 'resource-456';
          const expectedReply = 'I am doing well, thank you!';

          when(
            () => mockRepository.ask(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => expectedReply);

          // Act
          final result = await useCase(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          );

          // Assert
          expect(result, equals(expectedReply));
          verify(
            () => mockRepository.ask(
              userText: userText,
              threadId: threadId,
              resourceId: resourceId,
            ),
          ).called(1);
        },
      );

      test('should propagate exception from repository', () async {
        // Arrange
        const userText = 'Hello';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        final exception = Exception('Repository error');

        when(
          () => mockRepository.ask(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          () => mockRepository.ask(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });

      test('should handle empty user text', () async {
        // Arrange
        const userText = '';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Please provide a message.';

        when(
          () => mockRepository.ask(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act
        final result = await useCase(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        expect(result, equals(expectedReply));
        verify(
          () => mockRepository.ask(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });

      test('should handle long user text', () async {
        // Arrange
        final userText = 'A' * 1000; // Very long text
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'I received your long message.';

        when(
          () => mockRepository.ask(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act
        final result = await useCase(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        expect(result, equals(expectedReply));
        verify(
          () => mockRepository.ask(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });

      test(
        'should verify correct parameters are passed to repository',
        () async {
          // Arrange
          const userText = 'Test message';
          const threadId = 'test-thread-id';
          const resourceId = 'test-resource-id';
          const expectedReply = 'Test reply';

          when(
            () => mockRepository.ask(
              userText: any(named: 'userText'),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          ).thenAnswer((_) async => expectedReply);

          // Act
          await useCase(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          );

          // Assert
          verify(
            () => mockRepository.ask(
              userText: userText,
              threadId: threadId,
              resourceId: resourceId,
            ),
          ).called(1);
          verifyNever(
            () => mockRepository.ask(
              userText: any(named: 'userText', that: isNot(equals(userText))),
              threadId: any(named: 'threadId'),
              resourceId: any(named: 'resourceId'),
            ),
          );
        },
      );

      test('should handle multiple calls with different parameters', () async {
        // Arrange
        const userText1 = 'First message';
        const userText2 = 'Second message';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const reply1 = 'First reply';
        const reply2 = 'Second reply';

        when(
          () => mockRepository.ask(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((invocation) async {
          final userText = invocation.namedArguments[#userText] as String;
          return userText == userText1 ? reply1 : reply2;
        });

        // Act
        final result1 = await useCase(
          userText: userText1,
          threadId: threadId,
          resourceId: resourceId,
        );
        final result2 = await useCase(
          userText: userText2,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        expect(result1, equals(reply1));
        expect(result2, equals(reply2));
        verify(
          () => mockRepository.ask(
            userText: userText1,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
        verify(
          () => mockRepository.ask(
            userText: userText2,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });
    });
  });
}
