class ProjectListArguments {
  final String? userEmail;
  final String userRole;

  const ProjectListArguments({this.userEmail, this.userRole = 'observer'});
}

class AdminPageArguments {
  final String? userEmail;
  final String userRole;
  final String? initialProjectId;

  const AdminPageArguments({
    this.userEmail,
    this.userRole = 'admin',
    this.initialProjectId,
  });
}

class AdminNotificationsArguments {
  final String? userEmail;
  final String userRole;

  const AdminNotificationsArguments({this.userEmail, this.userRole = 'admin'});
}

class AdminProjectMapArguments {
  final String? userEmail;
  final String userRole;

  const AdminProjectMapArguments({this.userEmail, this.userRole = 'admin'});
}
