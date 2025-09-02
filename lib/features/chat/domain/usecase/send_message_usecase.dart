import 'package:test_task_oncom/features/chat/domain/repository/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repo);

  final ChatRepository _repo;

  Future<String> call({
    required String userText,
    required String threadId,
    required String resourceId,
  }) => _repo.ask(
    userText: userText,
    threadId: threadId,
    resourceId: resourceId,
  );
}
