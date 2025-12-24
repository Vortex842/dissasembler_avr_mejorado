/// [MathEvaluator]
///
/// PROPÓSITO:
/// Es la "Calculadora" del sistema. Su trabajo es resolver las pequeñas
/// expresiones matemáticas que aparecen dentro de las plantillas de nombres
/// de las instrucciones.
///
/// ¿POR QUÉ EXISTE ESTA CLASE?
/// En AVR, los operandos a menudo requieren un ajuste matemático antes de ser
/// mostrados.
///
/// Ejemplo 1 (Registros): La instrucción puede guardar el valor '0' en los bits,
/// pero eso se refiere al registro "R16". La plantilla será "R{d+16}".
/// Esta clase toma 'd=0' y calcula '0 + 16' -> Resultado: "R16".
///
/// Ejemplo 2 (Saltos): Un salto relativo puede definirse como "PC + k + 1".
/// Esta clase se encarga de realizar esa suma para mostrar la dirección final.
///
/// FUNCIONAMIENTO (ALGORITMO):
/// 1. Sustitución: Reemplaza variables (ej: "d") por sus valores (ej: "0"),
///    usando límites de palabra (\b) para no romper otras palabras.
/// 2. Jerarquía: Resuelve la expresión en dos pasadas para respetar el orden
///    matemático correcto (primero multiplicaciones *, luego sumas/restas +/-).
class MathEvaluator {
  /// Evalúa una expresión matemática simple contenida en una cadena, sustituyendo
  /// variables por sus valores numéricos.
  ///
  /// Soporta las operaciones básicas: Suma (+), Resta (-) y Multiplicación (*).
  /// Respeta la jerarquía de operaciones (la multiplicación se resuelve antes).
  ///
  /// - [expression]: La cadena con la expresión (ej: "d+16", "2*d+1").
  /// - [variables]: Un mapa con los valores de las variables a sustituir (ej: {"d": 0}).
  /// - Retorna el resultado entero de la evaluación.
  ///
  /// Ejemplo:
  ///
  /// expression = "2*d+1", variables = {"d": 5}
  ///
  /// Resultado = 11 (2*5 + 1)
  static int evaluate(String expression, Map<String, int> variables) {
    // 1. Sustituir las variables en el texto por sus números
    String processedExpr = _replaceVariables(expression, variables);

    // 2. Convertir el texto en una lista de números y operadores
    List<String> tokens = _tokenize(processedExpr);

    // 3. Resolver multiplicaciones (Prioridad Alta)
    _computeMultiplications(tokens);

    // 4. Resolver sumas y restas (Prioridad Baja)
    return _computeAdditionsAndSubtractions(tokens);
  }

  /// Sustituye las claves del mapa [variables] encontradas en [expr] por sus valores.
  /// Usa límites de palabra (\b) para evitar reemplazos parciales incorrectos.
  /// - [expr]: La expresión original con variables.
  /// - [variables]: Mapa de variables y sus valores numéricos.
  ///
  /// Retorna la expresión con las variables reemplazadas por números.
  ///
  /// - Ejemplo:
  ///
  /// expr = "2*d + K", variables = {"d": 5, "K": 10}
  ///
  /// Resultado = "2*5 + 10"
  static String _replaceVariables(String expr, Map<String, int> variables) {
    String result = expr;

    // Recorrer el mapa de variables
    // y reemplazar las claves por sus valores
    // en la expresión original
    variables.forEach(
      (key, value) {
        // \b asegura que si tenemos la variable "d", no reemplace la "d" dentro de "add"
        // sino solo las ocurrencias completas de " d ".
        result = result.replaceAll(
          RegExp(r'\b' + key + r'\b'),
          value.toString(),
        );
      },
    );
    return result;
  }

  /// Divide la expresión en una lista de tokens (números y operadores).
  ///
  /// - [expr]: La expresión matemática como cadena.
  ///
  /// Retorna una lista de cadenas, cada una siendo un número o un operador.
  ///
  /// Ejemplo: "10+5*2" -> ["10", "+", "5", "*", "2"]
  static List<String> _tokenize(String expr) {
    // Divide manteniendo los delimitadores (+, -, *)
    // (?=[...]) es Lookahead positivo (corta antes del operador)
    // (?<=[...]) es Lookbehind positivo (corta después del operador)
    return expr
        .split(RegExp(r'(?=[+\-*])|(?<=[+\-*])'))
        .map((e) => e.trim()) // Limpiar espacios extra
        .where((e) => e.isNotEmpty) // Eliminar vacíos
        .toList();
  }

  /// Procesa la lista de tokens buscando y resolviendo multiplicaciones (*).
  /// Modifica la lista [tokens] directamente (in-place).
  ///
  /// - [tokens]: Lista de tokens con números y operadores.
  ///
  /// No retorna nada; la lista se modifica directamente.
  ///
  /// Ejemplo:
  ///
  /// Antes: ["10", "+", "5", "*", "2"]
  ///
  /// Después: ["10", "+", "10"]
  ///
  /// porque 5*2 se resolvió a 10.
  static void _computeMultiplications(List<String> tokens) {
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '*') {
        // Obtener operandos
        int left = int.parse(tokens[i - 1]);
        int right = int.parse(tokens[i + 1]);

        int res = left * right;

        // Reemplazar: [..., '5', '*', '2', ...] -> [..., '10', ...]
        // Usamos i+2 como fin porque el rango final es exclusivo
        tokens.replaceRange(i - 1, i + 2, [res.toString()]);

        // Se hace i-- para "quedarte en el mismo sitio relativo" y no saltarte
        // el elemento que acaba de deslizarse hacia tu posición.
        // Ejemplo:
        // Índices:  0    1    2    3    4    5    6
        // Lista:  ['1', '+', '5', '*', '2', '-', '4']
        //                          ^
        //                          i = 3 (Aquí estamos)

        // Después de reemplazar:
        // Índices:  0    1    2    3    4
        // Lista:  ['1', '+', '10', '-', '4']
        //                          ^
        //                          i = 2
        // Si no hacemos i--, el próximo i++ nos llevaría a 3, y no queremos eso.
        // Queremos evaluar el '-' en la siguiente iteración, ya que este es un '-'
        // no parece dar problema, pero en caso de que hubiera otra multiplicación
        // seguida, nos la saltaríamos.
        i--;
      } else {
        i++;
      }
    }
  }

  /// Procesa la lista restante resolviendo sumas y restas secuencialmente.
  /// Asume que ya no quedan multiplicaciones.
  /// - [tokens]: Lista de tokens con números y operadores (+, -).
  /// Retorna el resultado final como entero.
  ///
  /// - Ejemplo: ["10", "+", "5", "-", "3"] -> 12 (10 + 5 - 3)
  static int _computeAdditionsAndSubtractions(List<String> tokens) {
    if (tokens.isEmpty) return 0;

    // Comenzamos con el primer número
    int result = int.parse(tokens[0]);

    // Avanzamos de 2 en 2: Operador -> Número
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      int num = int.parse(tokens[i + 1]);

      if (op == '+') {
        result += num;
      } else if (op == '-') {
        result -= num;
      }
    }

    return result;
  }
}
