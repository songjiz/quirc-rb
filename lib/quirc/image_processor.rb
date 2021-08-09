require "tempfile"

module Quirc
  class ImageProcessor
    attr_reader :pathname

    def initialize(path)
      @pathname = Pathname.new(path)
    end

    def to_grayscale(*)
      raise NotImplementedError
    end

    private
      def with_tempfile(name = nil)
        file = Tempfile.open(["quirc-", name])
        begin
          yield file
        ensure
          file && file.close!
        end
      end
  end
end
