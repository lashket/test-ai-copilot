import 'package:test_task_oncom/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:test_task_oncom/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);
  final ChatRemoteDataSource _remote;

  @override
  Future<String> ask({
    required String userText,
    required String threadId,
    required String resourceId,
  }) {
    return _remote.fetchAssistantReply(
      userText: userText,
      threadId: threadId,
      resourceId: resourceId,
    );
  }
}
