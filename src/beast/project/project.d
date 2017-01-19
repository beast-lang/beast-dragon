module beast.project.project;

import beast.project.configuration;

/// Global project instance
__gshared Project project = new Project;

/// Project wrapping class
final class Project {

public:
	ProjectConfiguration configuration;

}
