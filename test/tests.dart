import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:dart_webgl/dart_webgl.dart';

void main() {
  useHtmlEnhancedConfiguration();

  group('DoublyLinkedList tests', () {

    test('adding a single item', () {
      var list = new DoublyLinkedList()
        ..add('Hi');

      expect(list.size(), equals(1));
      expect(list.item(0), 'Hi');
    });

    test('adding two items', () {
      var list = new DoublyLinkedList()
        ..add('Hi')
        ..add('Hola');

      expect(list.size(), equals(2));
      expect(list.item(0), 'Hi');
      expect(list.item(1), 'Hola');
    });

    test('removing one item', () {
      var list = new DoublyLinkedList()
        ..add('Hi');

      expect(list.size(), equals(1));
      expect(list.remove(0), 'Hi');
    });

  });
}