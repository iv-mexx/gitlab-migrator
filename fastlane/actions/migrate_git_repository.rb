module Fastlane
  module Actions
    module SharedValues
    end

    require 'fileutils'
    class MigrateGitRepositoryAction < Action
      def self.run(params)
        Dir.mktmpdir do |tmpdir|
          Helper.log.info "Cloning Repository from #{params[:from_repo_url]} into #{tmpdir}"
          Actions.sh("git clone #{params[:from_repo_url]} #{tmpdir}")
          Dir.chdir(tmpdir) do
            Actions.sh("git remote add newOrigin #{params[:to_repo_url]}")
            Helper.log.info "Pushing all branches and tags to #{params[:to_repo_url]}"          
            Actions.sh("git push newOrigin --all")
            Actions.sh("git push newOrigin --tags")
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Migrates a git repository from one remote to another remote"
      end

      def self.details
        "Migration will checkout the whole repository from the source remote and push all branches and tags to a new remote. It is assumed that you already have access to both repositories"
      end

      def self.available_options
        # Define all options your action supports.
        [
          FastlaneCore::ConfigItem.new(key: :from_repo_url,
           env_name: "FL_MIGRATE_GIT_REPOSITORY_FROM_REPO_URL", 
           description: "The url of the source remote from which the repository should be cloned",
           verify_block: proc do |value|
            raise "No Source URL for MigrateGitRepositoryAction given, pass using `from_repo_url: 'url'`".red unless (value and not value.empty?)
          end),
          FastlaneCore::ConfigItem.new(key: :to_repo_url,
           env_name: "FL_MIGRATE_GIT_REPOSITORY_TO_REPO_URL", 
           description: "The url of the target remote to which the repository should be migrated",
           verify_block: proc do |value|
            raise "No Destination URL for MigrateGitRepositoryAction given, pass using `to_repo_url: 'url'`".red unless (value and not value.empty?)
          end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        []
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
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
