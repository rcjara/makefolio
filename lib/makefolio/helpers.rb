require 'yaml'

module Makefolio
  class Helpers
    # selects the text between '---' lines
    @@front_matter_pattern = /[\n]*[-]{3}[\n]([\s\S]*)[\n]*[-]{3}[\n]/

    def self.parse_front_matter(content)
      match = content.match(@@front_matter_pattern)

      if match.nil?
        { }
      else
        YAML.load(match[0])
      end
    end

    def self.strip_front_matter(content)
      content.gsub(@@front_matter_pattern, '').strip
    end

    def self.large_image_filename(filename)
      File.basename(filename, '.*') + '-lg' + File.extname(filename)
    end
  end
end