module Quirc
  module Ext
    module StringCamelize
      refine String do
        def camelize
          word = to_s.capitalize
          word.gsub!(/(?:_)([a-z\d]*)/) { $1.capitalize }
          word
        end
      end
    end
  end
end
