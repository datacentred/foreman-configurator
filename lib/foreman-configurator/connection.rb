require 'json'
require 'net/http'
require 'openssl'

module ForemanConfigurator
  class Connection

    # Checks parameters and cache away the configuration
    def initialize(config)
      unless config['api']['endpoint']
        raise ArgumentError.new('API endpoint required')
      end
      unless config['api']['username']
        raise ArgumentError.new('API username required')
      end
      unless config['api']['password']
        raise ArgumentError.new('API password required')
      end
      unless config['api']['cacert']
        raise ArgumentError.new('API cacert required')
      end
      unless config['api']['cert']
        raise ArgumentError.new('API cert required')
      end
      unless config['api']['key']
        raise ArgumentError.new('API key required')
      end
      @config = config['api']
    end

    # Perform a HTTP GET query against the API
    # Parse the JSON output, check that we haven't got too many
    # resources then return the results only
    def get(path, paged=false, results=1000)
      uri = "#{@config['endpoint']}#{path}"
      uri += "?per_page=#{results}" if paged
      uri = URI(uri)

      req = Net::HTTP::Get.new(uri)
      req.basic_auth(@config['username'], @config['password'])

      opt = {
        use_ssl: true,
        ca_file: @config['cacert'],
        cert: OpenSSL::X509::Certificate.new(File.read(@config['cert'])),
        key: OpenSSL::PKey::RSA.new(File.read(@config['key'])),
      }

      res = Net::HTTP.start(uri.hostname, uri.port, opt) do |http|
        http.request(req)
      end

      unless res.kind_of?(Net::HTTPSuccess)
        raise RuntimeError.new("Unexpected code #{res.code}: #{res.body}")
      end

      res = JSON.parse(res.body)

      if paged
        if res['total'] > results
          raise RuntimeError.new('Result overflow')
        end
        res = res['results']
      end

      res
    end

    # Perform a HTTP POST query against the API
    # Consumes native data which is translated to JSON before
    # being sent to the server
    def post(path, data)
      uri = URI("#{@config['endpoint']}#{path}")

      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@config['username'], @config['password'])
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(data)

      opt = {
        use_ssl: true,
        ca_file: @config['cacert'],
        cert: OpenSSL::X509::Certificate.new(File.read(@config['cert'])),
        key: OpenSSL::PKey::RSA.new(File.read(@config['key'])),
      }

      res = Net::HTTP.start(uri.hostname, uri.port, opt) do |http|
        http.request(req)
      end

      unless res.kind_of?(Net::HTTPSuccess)
        raise RuntimeError.new("Unexpected code #{res.code}: #{res.body}")
      end

      JSON.parse(res.body)
    end

    # Perform a HTTP PUT query against the API
    # Consumes native data which is translated to JSON before
    # being sent to the server
    def put(path, data)
      uri = URI("#{@config['endpoint']}#{path}")

      req = Net::HTTP::Put.new(uri)
      req.basic_auth(@config['username'], @config['password'])
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(data)

      opt = {
        use_ssl: true,
        ca_file: @config['cacert'],
        cert: OpenSSL::X509::Certificate.new(File.read(@config['cert'])),
        key: OpenSSL::PKey::RSA.new(File.read(@config['key'])),
      }

      res = Net::HTTP.start(uri.hostname, uri.port, opt) do |http|
        http.request(req)
      end

      unless res.kind_of?(Net::HTTPSuccess)
        raise RuntimeError.new("Unexpected code #{res.code}: #{res.body}")
      end

      JSON.parse(res.body)
    end

    # Perform a HTTP DELETE query against the API
    def delete(path)
      uri = URI("#{@config['endpoint']}#{path}")

      req = Net::HTTP::Delete.new(uri)
      req.basic_auth(@config['username'], @config['password'])

      opt = {
        use_ssl: true,
        ca_file: @config['cacert'],
        cert: OpenSSL::X509::Certificate.new(File.read(@config['cert'])),
        key: OpenSSL::PKey::RSA.new(File.read(@config['key'])),
      }

      res = Net::HTTP.start(uri.hostname, uri.port, opt) do |http|
        http.request(req)
      end

      unless res.kind_of?(Net::HTTPSuccess)
        raise RuntimeError.new("Unexpected code #{res.code}: #{res.body}")
      end
    end
  end
end
