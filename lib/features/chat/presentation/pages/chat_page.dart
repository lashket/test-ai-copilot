import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task_oncom/core/ui/inputs/app_input.dart';
import 'package:test_task_oncom/features/chat/presentation/bloc/chat_cubit.dart';

import 'package:test_task_oncom/features/chat/presentation/widgets/message_bubble.dart';
import 'package:test_task_oncom/generated/l10n.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).aiCopilot),
        actions: [
          IconButton(
            onPressed: cubit.resetThread,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (previousState, currentState) =>
                    previousState.messages != currentState.messages ||
                    previousState.isLoading != currentState.isLoading,
                builder: (context, state) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount:
                        state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.messages.length) {
                        final msg = state.messages[index];
                        return MessageBubbleFactory.create(msg);
                      }
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _TypingDots(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            BlocSelector<ChatCubit, ChatState, bool>(
              selector: (s) => s.isLoading,
              builder: (context, busy) => Padding(
                padding: const EdgeInsets.all(8),
                child: BaseInput(
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? S.of(context).typeSomething
                      : null,
                  onSubmit: (text) =>
                      context.read<ChatCubit>().sendUserMessage(text),
                  busy: busy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = _animationController.value;
        final activeDotIndex = (animationValue * 3).floor() % 3;
        return Row(
          children: List.generate(3, (dotIndex) {
            final isDotActive = dotIndex <= activeDotIndex;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isDotActive ? Colors.black87 : Colors.black26,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
