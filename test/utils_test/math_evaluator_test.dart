import 'package:test/test.dart';

import '../../bin/utils/math_evaluator_utils.dart';

void main() {
  group(
    'Evaluar expresiones matemáticas',
    () {
      final expressions = [
        'd',
        'r',
        'd+16',
        'K',
        'k',
      ];

      final variblesList = [
        {'d': 0, 'r': 1},
        {'d': 2, 'K': 10},
        {'d': 0, 'K': 255},
        {'k': 2048},
      ];

      test(
        'Evaluar ADC R{d}, R{r}',
        () {
          expect(MathEvaluator.evaluate('d', variblesList[0]), 0,
              reason: 'Evaluar d=0 para {d} debe ser 0');

          expect(MathEvaluator.evaluate('r', variblesList[0]), 1,
              reason: 'Evaluar r=1 para {r} debe ser 1');
        },
      );

      test(
        'Evaluar ANDI R{d+16}, 0x{K}',
        () {
          expect(MathEvaluator.evaluate('d+16', variblesList[1]), 18,
              reason: 'Evaluar d=2 para {d+16} debe ser 18');

          expect(MathEvaluator.evaluate('K', variblesList[1]), 10,
              reason: 'Evaluar K=10 para {K} debe ser 10');
        },
      );

      test(
        'Evaluar ADIW R{2*d+1+24}:R{2*d+24}, {K}',
        () {
          expect(MathEvaluator.evaluate('2*d+1+24', variblesList[2]), 25,
              reason: 'Evaluar d=0 para {2*d+1+24} debe ser 25');

          expect(MathEvaluator.evaluate('2*d+24', variblesList[2]), 24,
              reason: 'Evaluar d=0 para {2*d+24} debe ser 24');
        },
      );

      test(
        'Evaluar CALL 0x{k}',
        () {
          expect(MathEvaluator.evaluate('k', variblesList[3]), 2048,
              reason: 'Evaluar k=2048 para {k} debe ser 2048');
        },
      );
    },
  );
}
