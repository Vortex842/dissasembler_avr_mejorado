import 'package:test/test.dart';

import '../../bin/models/disassembled_model.dart';

void main() {
  group(
    'Pruebas para la clase DisassembledModel',
    () {
      final shortDecodedInstr = DisassembledModel(
        text: "LDI R16, 0xFF",
        countWords: 1,
        rawWord: 0xEFFF,
      );

      final longDecodedInstr = DisassembledModel(
        text: "LDS R16, 0x0150",
        countWords: 2,
        rawWord: 0x90000150,
      );

      test(
        'Debe almacenar correctamente los datos de una instrucción decodificada',
        () {
          expect(shortDecodedInstr.text, equals("LDI R16, 0xFF"),
              reason: 'El texto debe guardarse intacto');

          expect(shortDecodedInstr.countWords, equals(1),
              reason: 'La longitud debe coincidir');

          expect(shortDecodedInstr.rawWord, equals(0xEFFF),
              reason: 'El código hex original debe preservarse');
        },
      );

      test(
        'El metodo "toString" debe devolver el texto de la instrucción (para impresión limpia)',
        () {
          expect(longDecodedInstr.toString(), equals("LDS R16, 0x0150"),
              reason:
                  'El toString debe ser limpio para facilitar la impresión en consola en el main.');
        },
      );
    },
  );
}
