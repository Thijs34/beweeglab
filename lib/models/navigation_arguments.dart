import 'package:my_app/screens/admin_page/admin_models.dart';

class ProjectListArguments {
  final String? userEmail;
  final String userRole;

  const ProjectListArguments({this.userEmail, this.userRole = 'observer'});
}

class AdminPageArguments {
  final String? userEmail;
  final String userRole;
  final String? initialProjectId;
  final ProjectStatus? initialProjectStatus;

  const AdminPageArguments({
    this.userEmail,
    this.userRole = 'admin',
    this.initialProjectId,
    this.initialProjectStatus,
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

class ProfileSettingsArguments {
  final String? userEmail;
  final String userRole;

  const ProfileSettingsArguments({this.userEmail, this.userRole = 'observer'});
}
