require "quirc/version"
require "quirc/quirc"
require "quirc/image_processor"

module Quirc
  unless "".respond_to?(:camelize)
    require "quirc/ext/string_camelize"
    using Quirc::Ext::StringCamelize
  end

  class << self
    def recognize(path, width: nil, height: nil, image_processor: :vips, **options)
      processor = lookup_image_processor(image_processor, path)

      processor.to_grayscale(width: width, height: height, **options) do |image_data, width, height|
        Recognizer.new.recognize(image_data, width, height)
      end
    end

    private
      def lookup_image_processor(name, path)
        retrieve_image_processor_class(name).new(path)
      end

      def retrieve_image_processor_class(name)
        require "quirc/image_processor/#{name}"
      rescue LoadError => e
        raise "Could not find image processor for #{name} (#{e})"
      else
        Quirc::ImageProcessor.const_get(name.to_s.camelize)
      end
  end
end
