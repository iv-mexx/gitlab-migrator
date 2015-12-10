🤘 Migrate your private [gitlab](https://about.gitlab.com) projects 🤘

When using a private Gitlab instance, you can easily [import gitlab projects hosted on gitlab.com](http://doc.gitlab.com/ce/workflow/importing/import_projects_from_gitlab_com.html#project-importing-from-gitlab.com-to-your-private-gitlab-instance).

However, if you are already using a private gitlab instance you [are out of luck](http://feedback.gitlab.com/forums/176466-general/suggestions/4488044-add-import-export-functionality-for-projects?page=1&per_page=20)

This tool is here to help you migrate projects from one private gitlab instance to another. 

## Usage

This tool is based on [fastlane](https://fastlane.tools), different actions are implemented in therms of `lanes`.

### List Projects

You can print a list of all projects on the source gitlab with this command:

```
fastlane list_projects
```` 

This will also show projects that have already been migrated.

**Attention:** Keep in mind that projects are matched by name, so if you have migrated a project already and changed its name, it will **not** show up as migrated!

### Migrate a Project

You can migrate a specific project with this command:

```
fastlane migrate project:<project_path>
```

The `project_path` is the full path to the project in gitlab (including the namespace), you can take the a path as printed in the `list_projects` action. 

As an example, `fastlane migrate project:mexx-uni/pue1` will migrate the project `pue1` in the `mexx-uni` group.

## Setup

First, install the dependencies via 

```
bundle install
```

### Migrating several projects

If you need to migrate several projects at once, you can just create a small bash script that calls this tool for every project that should be migrated. 

```
#!/bin/bash

setopt shwordsplit
PI="namespace/project2 namespace/project2"

for i in $PI; do
	echo "Migrate Project: $i"
	fastlane migrate project:$i
done
```

### Github API Credentials

In order to access the gitlab instances, you'll need to provide their endpoint and an API access-token.

For fastlane to be able to access those, you will need have to provide some information in the `fastlane/.env` file. 
This repo already contains a file named `fastlane/env`. Edit this file: enter the gitlab endpoints and API access-tokens there, remove the comments and change the filename to `fastlane/.env`.

### Self-Signed SSH Certificates

If you can not connect to your gitlab API because of problems with a self signed SSH Certificate, you can use this to disable certificate verification:

```export GITLAB_API_HTTPARTY_OPTIONS="{verify: false}"```

I've put this into my `~/.zshrc` (because I did not find out how else to set this ENV variable so that it still works in the context of fastlane)

## Whats being migrated

### Projects

* description
* default_branch
* group
* namespace
* wiki_enabled
* wall_enabled
* issues_enabled
* snippets_enabled
* merge_requests_enabled
* public

### Labels

* name
* color

### Milestones

* project
* title
* description
* due_date

### Issues

* project
* title
* description
* assignee (on a best effort base)
* milestone
* labels
* notes (see caveats)

## Whats not being migrated

* Merge Requests + Notes
* Snippets + Notes
* System Hooks
* Users

### Repositories

After creating the project in the new gitlab, the git repository from the original source will be cloned and pushed to the new gitlab project

* all branches
* all tags

## Caveats

### Users

Users are not created in the target instance. Where users are necessary (e.g. as group members or issue assignees), existing users are matched by name. It is thus recommended to first create users in the new gitlab instance manually with the same name as in the original gitlab instance.

For users to be matched sucessfully, one of those has to be the same in both githab instances

* `name`
* `username`

### Groups

* Projects will be created in the same Namespace and for the same Group as in the original Gitlab
* Namespace and Group are matched by Name
  * Gitlab API is a little bit strange: When creating a group, a `group_id` and `namespace_id` are required. Existing project only has a namespace, but namespace are not actuall entities in the gitlab API. It is assumed that group and namespace have a 1:1 relation and `group_id` = `namespace_id`, also name and path for groups and namespaces are always equal. 
* Groups will be created when not yet existing
  * Groups will be populated with users on a 'best effort' basis (matched by name).
  * Due to the aforementioned strange behavior of the Gitlab API, **only** a group will be created (namespace can not be created) and the `group_id` will also be used as `namespace_id` for the new project

### Issues

* Issues are assigned to users on a 'best effort' (matched by name). 

### Notes

* All notes are posted in the name of the authenticated use who is performing the migration. It is not possible to change the author of a note. 
* Notes are posted with a specific header that notes the original author and the original date of the note


