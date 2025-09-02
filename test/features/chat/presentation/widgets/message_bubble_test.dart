import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_task_oncom/features/chat/domain/entities/message.dart';
import 'package:test_task_oncom/features/chat/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble', () {
    late Message userMessage;
    late Message assistantMessage;

    setUp(() {
      final now = DateTime.now();
      userMessage = Message(
        id: '1',
        role: MessageRole.user,
        content: 'Hello, how are you?',
        createdAt: now,
      );

      assistantMessage = Message(
        id: '2',
        role: MessageRole.assistant,
        content: 'I am doing well, thank you!',
        createdAt: now,
      );
    });

    group('SentMessageBubble', () {
      testWidgets('should display user message with correct styling', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentMessageBubble(message: userMessage),
            ),
          ),
        );

        // Assert
        expect(find.text('Hello, how are you?'), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, isA<Color>());
        expect(decoration?.borderRadius, isA<BorderRadius>());
      });

      testWidgets('should align to the right', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentMessageBubble(message: userMessage),
            ),
          ),
        );

        // Assert
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.crossAxisAlignment, equals(CrossAxisAlignment.end));
      });
    });

    group('ReceivedMessageBubble', () {
      testWidgets('should display assistant message with correct styling', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReceivedMessageBubble(message: assistantMessage),
            ),
          ),
        );

        // Assert
        expect(find.text('I am doing well, thank you!'), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, equals(Colors.grey[200]));
        expect(decoration?.borderRadius, isA<BorderRadius>());
      });

      testWidgets('should align to the left', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReceivedMessageBubble(message: assistantMessage),
            ),
          ),
        );

        // Assert
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
      });
    });

    group('MessageBubbleFactory', () {
      test('should create SentMessageBubble for user messages', () {
        // Act
        final bubble = MessageBubbleFactory.create(userMessage);

        // Assert
        expect(bubble, isA<SentMessageBubble>());
        expect(bubble.message, equals(userMessage));
      });

      test('should create ReceivedMessageBubble for assistant messages', () {
        // Act
        final bubble = MessageBubbleFactory.create(assistantMessage);

        // Assert
        expect(bubble, isA<ReceivedMessageBubble>());
        expect(bubble.message, equals(assistantMessage));
      });
    });

    group('MessageBubble common behavior', () {
      testWidgets('should have SelectionArea for text selection', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentMessageBubble(message: userMessage),
            ),
          ),
        );

        // Assert
        expect(find.byType(SelectionArea), findsOneWidget);
      });

      testWidgets('should have proper margin and padding', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentMessageBubble(message: userMessage),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(
          container.margin,
          equals(const EdgeInsets.symmetric(vertical: 6, horizontal: 8)),
        );
        expect(
          container.padding,
          equals(const EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
        );
      });
    });
  });
}
