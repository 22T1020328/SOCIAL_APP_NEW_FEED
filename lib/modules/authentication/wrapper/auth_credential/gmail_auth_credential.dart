import 'auth_credential.dart';

class GmailAuthCredential extends AuthCredential {
  const GmailAuthCredential({this.accessToken}) : super(_url);

  static const String _url = '/auth/gmail';

  @override
  Map<String, String?> asMap() {
    return {'gmail_token': accessToken};
  }

    final String? accessToken;
}

