import 'package:test/test.dart';

import '../../bin/services/dissasembled_service.dart';
import '../../bin/utils/instruction_loader.dart';

void main() {
  group(
    'DisassemblerService Tests',
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
    "bitPattern": "1110 KKKK dddd KKKK",
    "nameTemplate": "LDI R{d+16}, 0x{K}"
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

      // Cargamos las instrucciones en el desensamblador
      final dissasembler = DisassemblerService(instructions);

      test(
        'Debe decodificar correctamente una instrucción de 16 bits (LDI)',
        () {
          // LDI R16, 0x58
          // Opcode: 0xE508 -> 1110 0101 0000 1000
          // K = 0x58 (88), d = 0 (R16)
          final result = dissasembler.decode(0xE508);

          expect(result.text, equals('LDI R16, 0x58'),
              reason: 'Debió decodificar LDI correctamente');
          expect(result.countWords, equals(1), reason: 'LDI consume 1 palabra');
          expect(result.rawWord, equals(0xE508),
              reason: 'Raw word debe ser igual al opcode original');
        },
      );

      test(
        'Debe decodificar correctamente una instrucción de 32 bits (CALL)',
        () {
          // CALL 0x015F
          // Opcode: 0x940E -> 1001 0100 0000 1110
          // Second Opcode: 0x015F -> 0000 0001 0101 1111
          // La instrucción CALL usa ambas palabras:
          // Word 1: 0x940E (Parte fija + bits altos de k)
          // Word 2: 0x015F (Bits bajos de k)

          final word1 = 0x940E;
          final word2 = 0x015F;

          final result = dissasembler.decode(word1, nextWord: word2);

          expect(result.text, equals('CALL 0x015F'),
              reason: 'Debió decodificar CALL correctamente');

          expect(result.countWords, equals(2),
              reason: 'CALL consume 2 palabras');

          // La rawWord debe ser la combinación de ambas (32 bits)
          // (0x940E << 16) | 0x015F = 0x940E015F
          expect(result.rawWord, equals(0x940E015F));
        },
      );

      test(
        'Debe reportar error si falta la 2da palabra en instrucción larga',
        () {
          // Pasamos una CALL pero sin nextWord
          final result = dissasembler.decode(0x940E, nextWord: null);

          expect(
            result.text,
            equals('// ERROR: Instrucción incompleta (Falta 2da palabra)'),
            reason: 'Debe reportar error por falta de 2da palabra',
          );

          expect(
            result.countWords,
            equals(1),
            reason:
                'Si falla, debe avanzar 1 para no encasquillar el bucle infinito',
          );
        },
      );

      test('Debe manejar opcodes desconocidos elegantemente', () {
        final result =
            dissasembler.decode(0xFFFF); // 1111... (No está en nuestro mock)

        expect(
          result.text,
          contains('0xFFFF (Desconocida)'),
          reason: 'Debe indicar que es desconocida',
        );
        expect(
          result.countWords,
          equals(1),
          reason: 'Debe consumir 1 palabra',
        );
      });
    },
  );
}
