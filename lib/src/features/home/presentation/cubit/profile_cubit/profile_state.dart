import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String username;
  final String email;
  final bool isLoading;
  
  const ProfileState({
    this.username = 'Adam Wade Johnson Christopher Alexander Montgomery Wellington',
    this.email = 'verylongemailaddressforsometestingpurposes@mail.example.com',
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? username,
    String? email,
    bool? isLoading,
  }) {
    return ProfileState(
      username: username ?? this.username,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [username, email, isLoading];
}
