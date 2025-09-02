import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_task_oncom/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:test_task_oncom/features/chat/data/repository/chat_repository_impl.dart';
import 'package:test_task_oncom/features/chat/domain/repository/chat_repository.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  group('ChatRepository Contract Tests', () {
    late ChatRepository repository;
    late MockChatRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockChatRemoteDataSource();
      repository = ChatRepositoryImpl(mockDataSource);
    });

    group('ask method contract', () {
      test('should return Future<String> for valid inputs', () async {
        // Arrange
        const userText = 'Hello';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Hi there!';

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act
        final result = await repository.ask(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        expect(result, isA<String>());
        expect(result, equals(expectedReply));
      });

      test('should accept empty userText', () async {
        // Arrange
        const userText = '';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Please provide a message.';

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act & Assert
        final result = await repository.ask(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        expect(result, isA<String>());
      });

      test('should accept long userText', () async {
        // Arrange
        final userText = 'A' * 1000;
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Received long message.';

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act & Assert
        final result = await repository.ask(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        expect(result, isA<String>());
      });

      test('should propagate exceptions from underlying service', () async {
        // Arrange
        const userText = 'Hello';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        final exception = Exception('Service unavailable');

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.ask(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should require all parameters', () async {
        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => 'test reply');

        expect(
          () async => repository.ask(
            userText: 'test',
            threadId: 'test',
            resourceId: 'test',
          ),
          returnsNormally,
        );
      });
    });

    group('implementation specific behavior', () {
      test('should delegate to remote data source', () async {
        // Arrange
        const userText = 'Test message';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Test reply';

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act
        await repository.ask(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        verify(
          () => mockDataSource.fetchAssistantReply(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });

      test('should not modify parameters before delegation', () async {
        // Arrange
        const userText = '  Hello  ';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        const expectedReply = 'Hi';

        when(
          () => mockDataSource.fetchAssistantReply(
            userText: any(named: 'userText'),
            threadId: any(named: 'threadId'),
            resourceId: any(named: 'resourceId'),
          ),
        ).thenAnswer((_) async => expectedReply);

        // Act
        await repository.ask(
          userText: userText,
          threadId: threadId,
          resourceId: resourceId,
        );

        // Assert
        verify(
          () => mockDataSource.fetchAssistantReply(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });
    });
  });
}
