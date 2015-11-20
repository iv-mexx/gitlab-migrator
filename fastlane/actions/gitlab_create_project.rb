module Fastlane
  module Actions
    module SharedValues
    end

    require 'gitlab'

    class GitlabCreateProjectAction < Action
      def self.run(params)
        client = Gitlab.client(endpoint: params[:endpoint], private_token: params[:api_token])
        original_project = params[:project]
        Helper.log.info "Creating Project: #{original_project.path_with_namespace}"

        # Check if the Group and Namespace for the Project exist already
        group = ensure_group(client, original_project.namespace.name, original_project.namespace.path)

        # Create the project
        new_project = client.create_project(original_project.name,
          description: original_project.description,
          default_branch: original_project.default_branch,
          group_id: group.id,
          namespace_id: group.id,
          wiki_enabled: original_project.wiki_enabled,
          wall_enabled: original_project.wall_enabled,
          issues_enabled: original_project.issues_enabled,
          snippets_enabled: original_project.snippets_enabled,
          merge_requests_enabled: original_project.merge_reques,
          public: original_project.public
        )

        Helper.log.info("New Project created with ID: #{new_project.id} -  #{new_project}")
        new_project
      end

      # Given a group (with path-name) from the original project, 
      # checks if a group with the same path-name exists in the destination gitlab.
      # If necessary, a group with that path-name is created
      # The group (in the destination gitlab) is returned
      def self.ensure_group(client, group_name, group_path)
        Helper.log.info("Searching for group with name '#{group_name}' and path: '#{group_path}'")
        group = groups(client).select { |g| g.path == group_path}.first
        if group
          Helper.log.info("Existing group '#{group.name}' found")
        else
          Helper.log.info("Group '#{group_name}' does not yet exist, will be created now")
          group = client.create_group(group_name, group_path)
        end
        group
      end

      def self.groups(client)
        groups = []
        page = 1
        page_size = 20
        while true
          groups_age = client.groups(per_page: page_size, page: page)
          page += 1 
          groups += groups_age
          if groups_age.count < page_size
            break
          end
        end
        groups
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Creates a project in the target gitlab instance based on the input project"
      end

      def self.details
        "The input project is expected to come from the source gitlab instance. A new project will be created in the target gitlab instance based on the given project"
      end

      def self.available_options
        # Define all options your action supports.
        [
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "FL_GITLAB_CREATE_PROJECT_ENDPOINT",
                                       description: "Endpoint for GitlabeCreateProjectAction",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          raise "No Endpoint for GitlabeCreateProjectAction given, pass using `endpoint: 'url'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITLAB_CREATE_PROJECT_API_TOKEN",
                                       description: "API-Token for GitlabeCreateProjectAction",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          raise "No API-Token for GitlabeCreateProjectAction given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_GITLAB_CREATE_PROJECT_PROJECT",
                                       description: "The project that should be created in the target gitlab instance, is expected to be from the source gitlab instance",
                                       is_string: false)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        []
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
        "Returns the project that was created in the target gitlab instance"
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["cs_mexx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end