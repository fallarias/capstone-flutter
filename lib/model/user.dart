class User {
  int? id;
  String? lastname;
  String? firstname;
  String? middlename;
  String? department;
  String? email;
  String? account_type;
  String? token;

  User({
    this.id,
    this.lastname,
    this.firstname,
    this.middlename,
    this.department,
    this.email,
    this.account_type,
    this.token,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']?['user_id'], // Use null safety operator to prevent errors
      lastname: json['user']?['lastname'],
      firstname: json['user']?['firstname'],
      middlename: json['user']?['middlename'],
      department: json['user']?['department'],
      email: json['user']?['email'],
      account_type: json['user']?['account_type'],
      token: json['token'],
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastname': lastname,
      'firstname': firstname,
      'middlename': middlename,
      'department': department,
      'email': email,
      'account_type': account_type,
      'token': token,
    };
  }
}
