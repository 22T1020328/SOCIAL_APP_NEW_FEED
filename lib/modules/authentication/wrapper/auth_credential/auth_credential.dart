abstract class AuthCredential {
  const AuthCredential(this.url);

    Map<String, dynamic> asMap();

    final String url;

  @override
  String toString() => asMap().toString();
}

