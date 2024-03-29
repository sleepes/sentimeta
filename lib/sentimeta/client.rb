require 'open-uri'
require 'json'


module Sentimeta
  module Client

    class << self
      %i(criteria spheres objects catalog).each do |endpoint|
        define_method endpoint do |options={}|
          fetch(endpoint, options)[endpoint.to_s]
        end
      end

      def fetch endpoint, options={}
        url = [].tap do |components|
          components << Sentimeta.endpoint
          components << (options.delete(:sphere) || Sentimeta.sphere) if endpoint != :spheres
          components << endpoint
          components << options.delete(:id)
        end.compact.join('/')

        uri = URI.parse url
        uri.query = URI.encode_www_form(p: options.reverse_merge(lang: Sentimeta.lang).to_json)
        Sentimeta.logger.debug "  Sentimeta: #{ URI.unescape uri.to_s }"


        begin
          JSON.parse(uri.open.read)
        rescue
          raise Sentimeta::Error::Unreachable
        end
      end
    end

  end
end
