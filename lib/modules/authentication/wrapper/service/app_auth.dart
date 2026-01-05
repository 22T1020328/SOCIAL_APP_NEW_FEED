





import '../auth_credential/auth_credential.dart';
import '../models/login_data.dart';

class AppAuth {
  
  

  Future<LoginData?> signInWithCredential(AuthCredential credential) async {
    
    throw UnimplementedError('Use Firebase Authentication instead');
    
    /* Example Firebase Auth implementation:
    final auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: credential.email,
        password: credential.password,
      );
      
      return LoginData.fromFirebaseUser(userCredential.user);
    } catch (e) {
      
      return null;
    }
    */
  }

  Future<void> saveData(LoginData login) async {
    
    
    throw UnimplementedError('Firebase Auth handles tokens automatically');
  }
}

