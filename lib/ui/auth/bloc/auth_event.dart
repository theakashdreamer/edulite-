abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String mobile;
  final String name;
  LoginEvent(this.mobile, this.name);
}
