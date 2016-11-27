module Fastlane
  module Actions
    class ManualizeAction < Action
      def self.run(params)
        UI.message ""
        UI.message Terminal::Table.new(
          title: "Manualize".green,
          headings: ["Option", "Value"],
          rows: params.values
        )
        UI.message ""

        pbxproj_path = File.join(Dir.pwd, params[:project], 'project.pbxproj')
        pbxproj = File.read(pbxproj_path)

        target_id = /([0-9-A-Z]+) \/\* Unity-iPhone \*\/,/.match(pbxproj)[1]
        target_attributes = "#{target_id} = {\n\tProvisioningStyle = Manual;\n};"

        attributes = /\t+attributes = {\n\t+TargetAttributes = {\n((.|\n)*)\n\t+};\n\t+};/.match(pbxproj)

        File.write(pbxproj_path, pbxproj.sub!(attributes[1], "#{target_attributes}\n#{attributes[1]}"))
        UI.message "Updated target #{target_id} with ProvisioningStyle #{params[:style]}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set Provisioning Style"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_MANUALIZE_PROJECT",
                                       description: "Xcode Project Path",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :style,
                                       env_name: "FL_MANUALIZE_STYLE",
                                       description: "Provisioning Style",
                                       verify_block: proc do |value|
                                         options = ["Automatic", "Manual"]
                                         UI.user_error!("Provisioning Style must be either #{options.join(' or ')}") unless options.include?(value)
                                       end)
        ]
      end

      def self.authors
        ["thedoritos"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
