import 'package:test/test.dart';

import '../bin/utils/bit_manipulator_utils.dart';

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
    },
  );
}
