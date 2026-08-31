enum UserRole {
  cliente,
  prestador,
  admin;

  static UserRole fromString(String value) =>
      UserRole.values.firstWhere((e) => e.name == value);
}
