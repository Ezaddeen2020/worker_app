import 'project_model.dart';
import '../../profile/models/user_model.dart';

class ProjectWithUser {
  final Project project;
  final User user;

  const ProjectWithUser({required this.project, required this.user});

  ProjectWithUser copyWith({Project? project, User? user}) {
    return ProjectWithUser(project: project ?? this.project, user: user ?? this.user);
  }
}
