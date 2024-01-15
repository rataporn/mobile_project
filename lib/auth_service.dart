class AuthService {
  // Assume some data store for user information
  List<Map<String, String>> users = [];

  // Sign up a new user
  void signUp(String username, String email, String password) {
    users.add({'username': username, 'email': email, 'password': password});
  }

  // Check if a user exists with the given credentials
  bool signIn(String email, String password) {
    return users.any((user) => user['email'] == email && user['password'] == password);
  }
}
