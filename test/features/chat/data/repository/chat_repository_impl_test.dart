import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_task_oncom/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:test_task_oncom/features/chat/data/repository/chat_repository_impl.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  group('ChatRepositoryImpl', () {
    late ChatRepositoryImpl repository;
    late MockChatRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockChatRemoteDataSource();
      repository = ChatRepositoryImpl(mockRemoteDataSource);
    });

    group('ask', () {
      test(
        'should delegate to remote data source with correct parameters',
        () async {
          // Arrange
          const userText = 'Hello, how are you?';
          const threadId = 'thread-123';
          const resourceId = 'resource-456';
          const expectedReply = 'I am doing well, thank you!';

          when(
            () => mockRemoteDataSource.fetchAssistantReply(
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
          expect(result, equals(expectedReply));
          verify(
            () => mockRemoteDataSource.fetchAssistantReply(
              userText: userText,
              threadId: threadId,
              resourceId: resourceId,
            ),
          ).called(1);
        },
      );

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        const userText = 'Hello';
        const threadId = 'thread-123';
        const resourceId = 'resource-456';
        final exception = Exception('Network error');

        when(
          () => mockRemoteDataSource.fetchAssistantReply(
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

        verify(
          () => mockRemoteDataSource.fetchAssistantReply(
            userText: userText,
            threadId: threadId,
            resourceId: resourceId,
          ),
        ).called(1);
      });
    });
  });
}
