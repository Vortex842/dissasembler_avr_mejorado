import 'package:test/test.dart';

import '../../bin/utils/bit_manipulator_utils.dart';

void main() {
  group(
    'Probar la clase BitManipulator',
    () {
      test(
        'Extraer valores de patrón y palabra dados',
        () {
          // Patrón y palabra de ejemplo
          final pattern = "1110 KKKK dddd KKKK";
          final word = 0xE1C1; // Binario: 1110 0001 1100 0001

          // Llamar al método a probar
          final result = BitManipulator.extractValues(pattern, word);

          // Verificar los resultados esperados
          expect(result['K'], equals(0x11)); // KKKK KKKK = 0001 0001
          expect(result['d'], equals(0xC)); // dddd = 1100
        },
      );

      test(
        'Extraer valores con un patrón muy diferente',
        () {
          final pattern = "aaaa bbbb cccc dddd";
          final word = 0x1234; // Binario: 0001 0010 0011 0100

          final result = BitManipulator.extractValues(pattern, word);

          expect(result['a'], equals(1)); // aaaa = 0001
          expect(result['b'], equals(2)); // bbbb = 0010
          expect(result['c'], equals(3)); // cccc = 0011
          expect(result['d'], equals(4)); // dddd = 0100
        },
      );

      test(
        'Debe ignorar los bits fijos (0 y 1) y solo devolver variables',
        () {
          // Patrón con muchos 0s y 1s
          final pattern = "0000 1111 aaaa 0000";
          final word = 0xFFFF; // 1111 1111 1111 1111

          final result = BitManipulator.extractValues(pattern, word);

          // Solo debe existir la clave 'a'
          expect(result.length, equals(1));
          expect(result.containsKey('0'), isFalse);
          expect(result.containsKey('1'), isFalse);

          // 'a' coincide con 1111 (0xF)
          expect(result['a'], equals(0xF));
        },
      );
    },
  );
}
