require "image_processing/mini_magick"

module Quirc
  class ImageProcessor::MiniMagick < ImageProcessor
    def to_grayscale(*args)
      read_image do |image|
        with_tempfile("-grayscale-8bit.tiff") do |tempfile|  
          options = args.last.is_a?(Hash) ? args.pop : {}
          width, height = args
          width  ||= options.delete(:width) || image.width
          height ||= options.delete(:height) || image.height

          pipeline = ImageProcessing::MiniMagick.source(image)
          if width != image.width || height != image.height
            pipeline = pipeline.resize_to_fit(width, height, **options)
          end
          pipeline  = pipeline.depth(8)
          pipeline  = pipeline.colorspace("Gray")
          pipeline  = pipeline.alpha("remove")
          pipeline  = pipeline.convert("tiff")
          pipeline.call(destination: tempfile.path)
          processed = ::MiniMagick::Image.new(tempfile.path)

          tempfile.rewind
          yield tempfile.read, processed.width, processed.height
        end
      end
    end

    private
      def read_image
        require "mini_magick"

        image = ::MiniMagick::Image.new(pathname)
        if image.valid?
          yield image
        end
      rescue LoadError => e
        $stderr.puts "You don't have mini_magick installed in your application. Please add it to your Gemfile and run bundle install"
        raise e
      end
  end
end
