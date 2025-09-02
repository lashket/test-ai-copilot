import 'package:flutter_test/flutter_test.dart';
import 'package:test_task_oncom/features/chat/data/parsers/plain_data_parser.dart';

void main() {
  group('PlainChannelCollector', () {
    group('parseLineByTag', () {
      test('should return null for empty line', () {
        // Arrange
        const line = '';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, isNull);
      });

      test('should return null for whitespace only line', () {
        // Arrange
        const line = '   \t\n  ';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, isNull);
      });

      test('should return null when no colon separator found', () {
        // Arrange
        const line = '0 some text without colon';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, isNull);
      });

      test('should return null when colon is at the beginning', () {
        // Arrange
        const line = ':some text';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, isNull);
      });

      test('should return null when tag does not match', () {
        // Arrange
        const line = '1:"Hello world"';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, isNull);
      });

      test('should return payload when tag matches', () {
        // Arrange
        const line = '0:"Hello world"';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, equals('Hello world'));
      });

      test('should handle payload without quotes', () {
        // Arrange
        const line = '0:Hello world';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, equals('Hello world'));
      });

      test('should handle payload with extra whitespace', () {
        // Arrange
        const line = '0:  "Hello world"  ';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, equals('Hello world'));
      });

      test('should handle different tags', () {
        // Arrange
        const line = 'f:{"messageId":"msg-123"}';
        const tag = 'f';

        // Act
        final result = PlainChannelCollector.parseLineByTag(line, tag);

        // Assert
        expect(result, equals('{"messageId":"msg-123"}'));
      });
    });

    group('payloadToText', () {
      test('should return null for empty payload', () {
        // Arrange
        const payload = '';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, isNull);
      });

      test('should return null for whitespace only payload', () {
        // Arrange
        const payload = '   \t\n  ';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, isNull);
      });

      test('should return text without quotes when not JSON', () {
        // Arrange
        const payload = '"Hello world"';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('Hello world'));
      });

      test('should return decoded JSON string when valid JSON', () {
        // Arrange
        const payload = r'"Hello\nworld"';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('Hello\nworld'));
      });

      test('should return text as is when no quotes', () {
        // Arrange
        const payload = 'Hello world';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('Hello world'));
      });

      test('should handle single character payload', () {
        // Arrange
        const payload = 'a';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('a'));
      });

      test('should handle payload with only one quote', () {
        // Arrange
        const payload = '"incomplete';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('"incomplete'));
      });

      test('should handle JSON with escaped characters', () {
        // Arrange
        const payload = r'"Line 1\nLine 2\tTabbed"';

        // Act
        final result = PlainChannelCollector.payloadToText(payload);

        // Assert
        expect(result, equals('Line 1\nLine 2\tTabbed'));
      });
    });

    group('collectByTag', () {
      test('should return empty string for empty response', () {
        // Arrange
        const rawResponse = '';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals(''));
      });

      test('should collect all lines with matching tag', () {
        // Arrange
        const rawResponse = '''
0:"Hello"
1:"World"
0:"Flutter"
2:"Test"
0:"Dart"
''';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('HelloFlutterDart'));
      });

      test('should handle real server response format', () {
        // Arrange
        const rawResponse = r'''
f:{"messageId":"msg-XW5OeOIULZpecZDciuHTmSCn"}
0:"You can return items for a refund or exchange within 30 days of purchase. Just make sure they're in new condition and in their original packaging.\n\nTo start a return, head to [this link](https://customer-service."
0:"on-running.com/returns/new) and enter your order details. We generally cover the return shipping costs.\n\nOnce your return reaches our warehouse and is verified, your refund will be processed within 14 business days.\n\nIs"
0:" there a specific part of the return policy you'd like more details on?"
e:{"finishReason":"stop","usage":{"promptTokens":5849,"completionTokens":115},"isContinued":false}
d:{"finishReason":"stop","usage":{"promptTokens":5849,"completionTokens":115}}
''';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, contains('You can return items for a refund'));
        expect(result, contains('on-running.com/returns/new'));
        expect(result, contains('there a specific part of the return policy'));
        expect(result, isNot(contains('messageId')));
        expect(result, isNot(contains('finishReason')));
      });

      test('should handle Windows line endings', () {
        // Arrange
        const rawResponse = '0:"Hello"\r\n0:"World"\r\n1:"Test"';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('HelloWorld'));
      });

      test('should handle Unix line endings', () {
        // Arrange
        const rawResponse = '0:"Hello"\n0:"World"\n1:"Test"';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('HelloWorld'));
      });

      test('should handle mixed line endings', () {
        // Arrange
        const rawResponse = '0:"Hello"\r\n0:"World"\n0:"Test"';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('HelloWorldTest'));
      });

      test('should ignore empty lines', () {
        // Arrange
        const rawResponse = '''
0:"Hello"

0:"World"

1:"Test"
''';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('HelloWorld'));
      });

      test('should handle different tags in real scenario', () {
        // Arrange
        const rawResponse = '''
f:{"messageId":"msg-123"}
0:"First part of message"
0:"Second part of message"
e:{"finishReason":"stop"}
d:{"finishReason":"stop"}
''';

        // Act & Assert
        final fResult = PlainChannelCollector.collectByTag(rawResponse, 'f');
        expect(fResult, equals('{"messageId":"msg-123"}'));

        final zeroResult = PlainChannelCollector.collectByTag(rawResponse, '0');
        expect(
          zeroResult,
          equals('First part of messageSecond part of message'),
        );

        final eResult = PlainChannelCollector.collectByTag(rawResponse, 'e');
        expect(eResult, equals('{"finishReason":"stop"}'));

        final dResult = PlainChannelCollector.collectByTag(rawResponse, 'd');
        expect(dResult, equals('{"finishReason":"stop"}'));
      });

      test('should handle malformed lines gracefully', () {
        // Arrange
        const rawResponse = '''
0:"Valid line"
invalid line without colon
0:"Another valid line"
:invalid line starting with colon
0:"Final valid line"
''';
        const tag = '0';

        // Act
        final result = PlainChannelCollector.collectByTag(rawResponse, tag);

        // Assert
        expect(result, equals('Valid lineAnother valid lineFinal valid line'));
      });
    });
  });
}
