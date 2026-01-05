import 'login_data.dart';

class Login {
  final int? code;
  final LoginData? data;

  Login({this.code, this.data});

  factory Login.fromJSON(Map<String, dynamic> json) {
    final int? code = json['code'] as int?;
    LoginData? data;
    if (code == 200) {
      data = LoginData.fromJSON(json['data'] as Map<String, dynamic>);
    }
    return Login(code: code, data: data);
  }
}

