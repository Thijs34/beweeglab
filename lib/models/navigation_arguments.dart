class ProjectListArguments {
  final String? userEmail;
  final String userRole;

  const ProjectListArguments({this.userEmail, this.userRole = 'observer'});
}

class AdminPageArguments {
  final String? userEmail;
  final String userRole;

  const AdminPageArguments({this.userEmail, this.userRole = 'admin'});
}

class AdminNotificationsArguments {
  final String? userEmail;
  final String userRole;

  const AdminNotificationsArguments({this.userEmail, this.userRole = 'admin'});
}
