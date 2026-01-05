class LoginData {
  final String? accessToken;
  final String? refreshToken;
  final String? oauthId;
  final int? expiresIn;
  final bool? isNew;
  final bool? hasUsernamePassword;

  LoginData({
    this.accessToken,
    this.refreshToken,
    this.oauthId,
    this.expiresIn,
    this.isNew,
    this.hasUsernamePassword,
  });

  factory LoginData.fromJSON(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      oauthId: json['oauth_id'] as String?,
      expiresIn: json['expires_in'] as int?,
      isNew: json['is_new'] as bool?,
      hasUsernamePassword: json['has_username_password'] as bool?,
    );
  }
}

