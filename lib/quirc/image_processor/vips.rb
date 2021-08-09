require "image_processing/vips"

module Quirc
  class ImageProcessor::Vips < ImageProcessor
    def to_grayscale(*args)
      read_image do |image|
        with_tempfile("-grayscale-8bit.tiff") do |tempfile|
          options = args.last.is_a?(Hash) ? args.pop : {}
          width, height = args
          width  ||= options.delete(:width) || image.width
          height ||= options.delete(:height) || image.height
          pipeline = ImageProcessing::Vips.source(image)
          if width != image.width || height != image.height
            pipeline = pipeline.resize_to_fit(width, height, **options)
          end
          pipeline = pipeline.colourspace("b_w")
          pipeline = pipeline.flatten
          pipeline = pipeline.convert("tiff")
          image    = pipeline.call(save: false)
          pipeline.call(destination: tempfile.path)
          tempfile.rewind
          yield tempfile.read, image.width, image.height
        end
      end
    end

    private
      def read_image
        require "ruby-vips"

        image = ::Vips::Image.new_from_file(pathname.to_s)

        if valid_image?(image)
          yield image
        end
      rescue LoadError => e
        $stderr.puts "You don't have ruby-vips installed in your application. Please add it to your Gemfile and run bundle install"
        raise e
      ensure
        image = nil
      end

      def valid_image?(image)
        image.avg
        true
      rescue ::Vips::Error
        false
      end
  end
end
