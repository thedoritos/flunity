module Fastlane
  module Actions
    class UninstallProfileAction < Action
      def self.run(params)

        UI.message ""
        UI.message Terminal::Table.new(
          title: "Uninstall Profile".green,
          headings: ["Option", "Value"],
          rows: params.values
        )
        UI.message ""

        # see http://qiita.com/mattak@github/items/dcb25ad7e12501d1525d
        xml = sh("security cms -D -i #{params[:file]}")

        require 'rexml/document'
        doc = REXML::Document.new xml

        uuid = doc.elements.to_a('plist/dict/key')
          .find { |e| e.text == 'UUID' }
          .next_element
          .text

        profile_name = "#{uuid}.mobileprovision"
        profile_path = File.join(Dir.home, 'Library/MobileDevice/Provisioning Profiles', profile_name)

        unless File.exists?(profile_path)
          UI.message "Provisioning Profile is not installed at #{profile_path}"
          return
        end

        File.delete(profile_path)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uninstall provisioning profile from Xcode"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_UNINSTALL_PROFILE_FILE",
                                       description: "Provisioning profile",
                                       verify_block: proc do |value|
                                          UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
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
