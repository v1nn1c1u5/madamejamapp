/// Validadores reutilizáveis para formulários.
abstract final class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    final r = required(value, field: 'E-mail');
    if (r != null) return r;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    final r = required(value, field: 'Senha');
    if (r != null) return r;
    if (value!.length < 6) {
      return 'A senha deve ter ao menos 6 caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return 'As senhas não conferem';
    }
    return null;
  }
}
