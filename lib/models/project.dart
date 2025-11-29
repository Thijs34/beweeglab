/// Project model representing a field observation project
class Project {
  final String id;
  final String name;
  final String location;
  final String? description;

  const Project({
    required this.id,
    required this.name,
    required this.location,
    this.description,
  });

  // Mock data for visual demonstration
  static List<Project> getMockProjects() {
    return [
      const Project(
        id: '1',
        name: 'Parkstraat Recreation Area',
        location: 'Amsterdam Noord',
        description: 'Public park observation study',
      ),
      const Project(
        id: '2',
        name: 'City Center Sports Facilities',
        location: 'Amsterdam Centrum',
        description: 'Urban sports area analysis',
      ),
      const Project(
        id: '3',
        name: 'Community Basketball Courts',
        location: 'Rotterdam West',
        description: 'Youth activity monitoring',
      ),
    ];
  }
}
