import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task_oncom/core/data/dio_client.dart';
import 'package:test_task_oncom/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:test_task_oncom/features/chat/data/repository/chat_repository_impl.dart';
import 'package:test_task_oncom/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:test_task_oncom/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:test_task_oncom/features/chat/presentation/pages/chat_page.dart';
import 'package:test_task_oncom/generated/l10n.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ChatRemoteDataSource(dioClient)),
        RepositoryProvider(
          create: (ctx) => ChatRepositoryImpl(ctx.read<ChatRemoteDataSource>()),
        ),
        RepositoryProvider(
          create: (ctx) => SendMessageUseCase(ctx.read<ChatRepositoryImpl>()),
        ),
      ],
      child: BlocProvider(
        create: (ctx) => ChatCubit(ctx.read<SendMessageUseCase>()),
        child: MaterialApp(
          title: 'ConvAI Copilot',
          localizationsDelegates: const [
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1E88E5),
            useMaterial3: true,
          ),
          home: const ChatPage(),
        ),
      ),
    );
  }
}
