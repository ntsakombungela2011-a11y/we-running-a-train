import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/model/common/id.dart';

part 'auth_controller.freezed.dart';
part 'auth_controller.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required LightUser user,
    required String token,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
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

class AuthController extends Notifier<AuthUser?> {
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
