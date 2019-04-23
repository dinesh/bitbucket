# encoding: utf-8

require 'faraday'

module BitBucket
  require 'hashie/mash'
  class Mash < ::Hashie::Mash
    disable_warnings
  end

  class Response::Mashify < Response
    define_parser do |body|
      Mash.new body
    end

    def parse(body)
      case body
      when Hash
        self.class.parser.call body
      when Array
        body.map { |item| item.is_a?(Hash) ? self.class.parser.call(item) : item }
      else
        body
      end
    end
  end # Response::Mashify
end # BitBucket
