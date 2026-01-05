import '../models/login_data.dart';
abstract class AuthService {

  Future<LoginData?> loginWithGmail();
  

}

