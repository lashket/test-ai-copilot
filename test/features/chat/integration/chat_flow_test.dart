import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_task_oncom/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:test_task_oncom/features/chat/data/repository/chat_repository_impl.dart';
import 'package:test_task_oncom/features/chat/domain/repository/chat_repository.dart';
import 'package:test_task_oncom/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:test_task_oncom/features/chat/presentation/bloc/chat_cubit.dart';

// Mock для реального data source
class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  group('Chat Flow Integration Tests', () {
    late MockChatRemoteDataSource mockDataSource;
    late ChatRepository repository;
    late SendMessageUseCase useCase;
    late ChatCubit cubit;

    setUp(() {
      mockDataSource = MockChatRemoteDataSource();
      repository = ChatRepositoryImpl(mockDataSource);
      useCase = SendMessageUseCase(repository);
      cubit = ChatCubit(useCase);
    });

    tearDown(() {
      cubit.close();
    });

    test('should complete full chat flow from UI to data source', () async {
      // Arrange
      const userMessage = 'Hello, how are you?';
      const assistantReply = 'I am doing well, thank you!';

      when(
        () => mockDataSource.fetchAssistantReply(
          userText: any(named: 'userText'),
          threadId: any(named: 'threadId'),
          resourceId: any(named: 'resourceId'),
        ),
      ).thenAnswer((_) async => assistantReply);

      // Act
      await cubit.sendUserMessage(userMessage);

      // Assert
      expect(cubit.state.messages.length, equals(2));
      expect(cubit.state.messages[0].content, equals(userMessage));
      expect(cubit.state.messages[1].content, equals(assistantReply));
      expect(cubit.state.isLoading, isFalse);

      verify(
        () => mockDataSource.fetchAssistantReply(
          userText: userMessage,
          threadId: cubit.state.threadId,
          resourceId: cubit.state.resourceId,
        ),
      ).called(1);
    });

    test('should handle errors in full flow', () async {
      // Arrange
      const userMessage = 'Hello';
      final exception = Exception('Network error');

      when(
        () => mockDataSource.fetchAssistantReply(
          userText: any(named: 'userText'),
          threadId: any(named: 'threadId'),
          resourceId: any(named: 'resourceId'),
        ),
      ).thenThrow(exception);

      // Act
      await cubit.sendUserMessage(userMessage);

      // Assert
      expect(cubit.state.messages.length, equals(1));
      expect(cubit.state.messages[0].content, equals(userMessage));
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, equals('Exception: Network error'));
    });
  });
}
