import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicialización del servicio de Google.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _inicializarGoogle() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      serverClientId:
          '59274529036-oo1tbid4js7l2vissh3etuj9490f74lp.apps.googleusercontent.com',
    );

    _googleInitialized = true;
  }

  // Obtener el usuario autenticado.
  User? get usuarioActual => _auth.currentUser;

  // Escuchar cambios de sesión.
  Stream<User?> get cambiosSesion => _auth.authStateChanges();

  // Registrar una cuenta con correo y contraseña.
  Future<UserCredential> registrarConCorreo({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('No fue posible registrar la cuenta: $e');
    }
  }

  // Iniciar sesión con correo y contraseña.
  Future<UserCredential> iniciarSesionConCorreo({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('No fue posible iniciar sesión: $e');
    }
  }

  // Recuperar la contraseña por correo electrónico.
  Future<void> recuperarContrasena({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('No fue posible enviar el correo de recuperación: $e');
    }
  }

  // Iniciar sesión con Google.
  Future<UserCredential> iniciarSesionGoogle() async {
    try {
      if (!_googleInitialized) {
        await _inicializarGoogle();
      }

      final GoogleSignInAccount cuenta = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication autenticacion = cuenta.authentication;

      final OAuthCredential credencial = GoogleAuthProvider.credential(
        idToken: autenticacion.idToken,
      );

      return await _auth.signInWithCredential(credencial);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('No fue posible iniciar sesión con Google: $e');
    }
  }

  // Cerrar sesión.
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
