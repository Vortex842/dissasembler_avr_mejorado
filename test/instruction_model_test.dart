import 'package:test/test.dart';

import '../bin/models/instruction_model.dart';

void main() {
  group(
    'InstructionModel test',
    () {
      final jsonAVRInstructions = [
        {
          "bitPattern": "0001 11rd dddd rrrr",
          "nameTemplate": "ADC R{d}, R{r}",
        },
        {
          "bitPattern": "0000 11rd dddd rrrr",
          "nameTemplate": "ADD R{d}, R{r}",
        },
        {
          "bitPattern": "1001 010k kkkk 111k",
          "secondBitPattern": "kkkk kkkk kkkk kkkk",
          "nameTemplate": "CALL 0x{k}"
        },
      ];

      final shortInstr = InstructionModel.fromJson(jsonAVRInstructions[0]);
      final longInstr = InstructionModel.fromJson(jsonAVRInstructions[2]);

      test(
        'Debe obtenerse la mascara y el patron de la instrucción correctamente',
        () {
          // 1. Validar la MÁSCARA (Mask)
          // ADC: "0001 11rd dddd rrrr" -> Fijos: 0001 11.. .... ....
          // Mask: 1111 1100 0000 0000 -> 0xFC00
          expect(shortInstr.mask, equals(0xFC00),
              reason:
                  'La máscara debe cubrir los primeros 6 bits fijos (0001 11.. .... ...) de la instrucción ADC.');

          // 2. Validar el PATRÓN (Pattern)
          // Pattern: 0001 1100 0000 0000 -> 0x1C00
          expect(shortInstr.pattern, equals(0x1C00),
              reason:
                  'El patrón debe coincidir con el valor de los bits fijos definidos para ADC.');

          // 3. Validaciones negativas (Sanity Checks)
          expect(shortInstr.mask, isNot(equals(0xFFFF)),
              reason:
                  'La máscara NO debe ser 0xFFFF porque hay variables (r, d) que deben ignorarse.');

          expect(shortInstr.pattern, isNot(equals(0x1FFF)),
              reason:
                  'El patrón NO debe tener bits encendidos en posiciones donde van las variables.');
        },
      );

      test(
        'Debe hacerse match solo con una instrucción, ej: ADC R17, R1',
        () {
          // Ejemplo de instruccion correcta: ADC R17, R1
          // mask: 1111 1100 0000 0000
          // pattern: 0001 1100 0000 0000
          final testInstr = 0x1D11; // 0001 1101 0001 0001
          // d: 10001 (R17)
          // r: 00001 (R1)

          // Ejemplo de instruccion incorrecta: ADD R2, R1
          // mask: 1111 1100 0000 0000
          // pattern: 0001 1100 0000 0000
          final otherInstr = 0x0C21; // 0000 1100 0010 0001
          // d: 00010 (R2)
          // r: 00001 (R1)

          // Aplicar la mascara a cada instruccion
          // 0001 1101 0001 0001 & 1111 1100 0000 0000 = 0001 1100 0000 0000
          final maskedInstr = testInstr & shortInstr.mask;

          // 0000 1100 0010 0001 & 1111 1100 0000 0000 = 0000 1100 0000 0000
          final maskedOtherInstr = otherInstr & shortInstr.mask;

          // Verificar el match con una instruccion correcta
          expect(maskedInstr, equals(shortInstr.pattern),
              reason:
                  'La instrucción "ADC R17, R1" debe hacer match con el patrón definido.');

          // Verificar que no haga match con una instruccion incorrecta
          expect(maskedOtherInstr, isNot(equals(shortInstr.pattern)),
              reason:
                  'La instrucción "ADD R2, R1" NO debe hacer match con el patrón de ADC.');

          // Ahora usando el metodo "match" de la clase InstructionModel
          expect(shortInstr.match(testInstr), isTrue,
              reason:
                  'El método match debe retornar true para la instrucción "ADC R17, R1".');

          expect(
              shortInstr.match(otherInstr), isNot(equals(shortInstr.pattern)),
              reason:
                  'La instrucción "ADD R2, R1" NO debe hacer match con el patrón de ADC.');
        },
      );

      test(
        'Debe identificar si una instrucción es larga (32 bits) o corta (16 bits)',
        () {
          expect(longInstr.isLongInstruction, isTrue,
              reason:
                  'La instrucción CALL debe ser reconocida como una instrucción larga (32 bits).');

          expect(shortInstr.secondBitPattern, isNull,
              reason:
                  'La instrucción ADC no debe tener un segundo patrón de bits.');

          expect(shortInstr.isLongInstruction, isFalse,
              reason:
                  'La instrucción ADC debe ser reconocida como una instrucción corta (16 bits).');

          expect(longInstr.secondBitPattern, equals('kkkk kkkk kkkk kkkk'),
              reason:
                  'La instrucción CALL debe tener un segundo patrón de bits.');
        },
      );

      test(
        'El metodo "toString" debe generar una descripción legible para depuración',
        () {
          // InstructionModel
          //  nameTemplate: ADC R{d}, R{r}

          //  bitPattern: 0001 11rd dddd rrrr
          //  secondBitPattern: null
          //  mask: 0xFC00
          //  pattern: 0x1C00
          final text = shortInstr.toString();

          expect(text, contains('nameTemplate: ADC R{d}, R{r}'),
              reason: 'Debe mostrar la plantilla correcta del nombre');

          expect(text, contains('bitPattern: 0001 11rd dddd rrrr'),
              reason: 'Debe mostrar el patrón de bits correcto');

          expect(text, contains('secondBitPattern: null'),
              reason:
                  'Debe mostrar el patrón correcto de bits secundario correcto');

          expect(text, contains('mask: 0xFC00'),
              reason:
                  'Debe mostrar la máscara correcta en formato hexadecimal');

          expect(text, contains('pattern: 0x1C00'),
              reason: 'Debe mostrar el patrón correcto en formato hexadecimal');
        },
      );
    },
  );
}
