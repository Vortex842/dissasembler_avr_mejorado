class InstructionLoadException implements Exception {
  final String message;
  InstructionLoadException(this.message);
  @override
  String toString() => 'Error cargando instrucciones: $message';
}
