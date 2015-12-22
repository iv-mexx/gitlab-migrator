module Fastlane
  module Actions
    module SharedValues
    end

    require 'gitlab'

    class GitlabGetProjectsAction < Action
      def self.run(params)
        client = Gitlab.client(endpoint: params[:endpoint], private_token: params[:api_token])
        client.projects.auto_paginate
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns a list of projects gitlab project from the given gitlab instance"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "Only projects the user has access to will be returned"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "FL_GITLAB_GET_RPROJECTS_ENDPOINT",
                                       description: "Endpoint for GitlabGetProjectsAction",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          raise "No Endpoint for GitlabGetProjectsAction given, pass using `endpoint: 'url'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITLAB_GET_RPROJECTS_API_TOKEN",
                                       description: "API-Token for GitlabGetProjectsAction",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          raise "No API-Token for GitlabGetProjectsAction given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        []
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
        "Returns a list of projects from the given gitlab instance. Only projects visible to the user are returned"
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
