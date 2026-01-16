import 'package:test/test.dart';

import '../../bin/utils/instruction_loader.dart';

void main() {
  group(
    'Probar la clase InstructionLoader',
    () {
      final instructionsJSON = '''
[
  {
    "bitPattern": "0001 11rd dddd rrrr",
    "nameTemplate": "ADC R{d}, R{r}"
  },
  {
    "bitPattern": "0000 11rd dddd rrrr",
    "nameTemplate": "ADD R{d}, R{r}"
  },
  {
    "bitPattern": "1001 010k kkkk 111k",
    "secondBitPattern": "kkkk kkkk kkkk kkkk",
    "nameTemplate": "CALL 0x{k}"
  }
]
''';

      // Devuelve la lista de instrucciones cargadas, de tipo InstructionModel
      final instructions =
          InstructionLoader.parseInstructions(instructionsJSON);

      test(
        'Cargar instrucciones AVR desde JSON',
        () {
          // Verificar que se cargaron instrucciones
          expect(instructions, isNotEmpty,
              reason: 'Se esperaba al menos una instrucción cargada.');

          // Verificar que la primera instrucción es ADC
          final firstInstruction = instructions.first;
          expect(firstInstruction.nameTemplate, equals('ADC R{d}, R{r}'),
              reason:
                  'La primera instrucción debería ser ADC según el archivo de prueba.');

          expect(firstInstruction.bitPattern, equals('0001 11rd dddd rrrr'),
              reason:
                  'El patrón de bits de la primera instrucción no coincide con el esperado.');
        },
      );

      test(
        'Verificar la intruccion larga',
        () {
          // Buscar la instrucción CALL
          final callInstruction = instructions[2];

          // Verificar que es una instrucción larga
          expect(callInstruction.isLongInstruction, isTrue,
              reason:
                  'La instrucción CALL debe ser reconocida como larga (32 bits).');

          expect(callInstruction.bitPattern, equals('1001 010k kkkk 111k'),
              reason:
                  'El primer patrón de bits de la instrucción CALL no coincide con el esperado.');

          // Verificar el segundo patrón de bits
          expect(
              callInstruction.secondBitPattern, equals('kkkk kkkk kkkk kkkk'),
              reason:
                  'El segundo patrón de bits de la instrucción CALL no coincide con el esperado.');
        },
      );
    },
  );
}
