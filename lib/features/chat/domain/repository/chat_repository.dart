abstract interface class ChatRepository {
  Future<String> ask({
    required String userText,
    required String threadId,
    required String resourceId,
  });
}
