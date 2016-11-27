module Fastlane
  module Actions
    class UnityAction < Action
      def self.run(params)
        build_cmd = "#{params[:executable]}"
        build_cmd << " -projectPath #{params[:project_path]}"
        build_cmd << " -quit"
        build_cmd << " -nographics" if params[:nographics]
        build_cmd << " -batchmode"
        build_cmd << " -logFile #{params[:log_file]}" if params[:log_file]
        build_cmd << " -runEditorTests" if params[:run_editor_tests]
        build_cmd << " -executeMethod #{params[:execute_method]}" unless params[:execute_method].nil?
        build_cmd << " -resultsFileDirectory=#{params[:results_file_directory]}" if params[:results_file_directory]

        UI.message ""
        UI.message Terminal::Table.new(
          title: "Unity".green,
          headings: ["Option", "Value"],
          rows: params.values
        )
        UI.message ""

        UI.message "Start running"
        UI.message "Check out logs at \"~/Library/Logs/Unity/Editor.log\" if the build failed"
        UI.message ""

        sh build_cmd

        UI.success "Completed"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run Unity in batch mode"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :executable,
                                       env_name: "FL_UNITY_EXECUTABLE",
                                       description: "Path for Unity executable",
                                       default_value: "/Applications/Unity/Unity.app/Contents/MacOS/Unity"),
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: "FL_UNITY_PROJECT_PATH",
                                       description: "Path for Unity project",
                                       default_value: "#{Dir.pwd}"),

          FastlaneCore::ConfigItem.new(key: :nographics,
                                       env_name: "FL_UNITY_NOGRAPHICS",
                                       description: "Initialize graphics device or not",
                                       is_string: false,
                                       default_value: true),

          FastlaneCore::ConfigItem.new(key: :run_editor_tests,
                                       env_name: "FL_UNITY_RUN_EDITOR_TESTS",
                                       description: "Option to run editor tests",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :results_file_directory,
                                       env_name: "FL_UNITY_RESULTS_FILE_DIRECTORY",
                                       description: "Path for integration test results",
                                       optional: true,
                                       default_value: nil),
          FastlaneCore::ConfigItem.new(key: :log_file,
                                       env_name: "FL_UNITY_LOG_FILE",
                                       description: "Specify where the Editor or Windows/Linux/OSX standalone log file will be written",
                                       optional: true,
                                       default_value: nil),
          FastlaneCore::ConfigItem.new(key: :execute_method,
                                       env_name: "FL_UNITY_EXECUTE_METHOD",
                                       description: "Method to execute",
                                       optional: true,
                                       default_value: nil)
        ]
      end

      def self.authors
        ["thedoritos"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
