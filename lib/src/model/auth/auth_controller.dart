import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/model/common/id.dart';

class AuthUser {
  final LightUser user;
  final String token;

  const AuthUser({
    required this.user,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      user: LightUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AuthUser?>(
  AuthController.new,
  name: 'AuthControllerProvider',
);

final isLoggedInProvider = Provider.autoDispose<bool>((Ref ref) {
  return true;
}, name: 'IsLoggedInProvider');

final signInMutation = Mutation<void>();
final signOutMutation = Mutation<void>();

class AuthController extends AutoDisposeNotifier<AuthUser?> {
  @override
  AuthUser? build() {
    return const AuthUser(
      user: LightUser(
        id: UserId('offline_user'),
        name: 'Offline User',
      ),
      token: 'offline_token',
    );
  }

  Future<void> signIn() async {}
  Future<void> signOut() async {}
  Future<void> checkToken() async {}
}
