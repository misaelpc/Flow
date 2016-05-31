module Net
  class Request
    extend Actions
    include Request::Stubbable

    attr_reader :configuration, :session, :base_url

    def initialize(url, options = {}, session = nil)
      @client = Com::Squareup::Okhttp::OkHttpClient.new
      @base_url = url
      @options = options
      @session = session
      @configuration = {}

      set_defaults
      configure
    end

    def run(&callback)
      return if stub!(&callback)

      Task.background do
        request = Com::Squareup::Okhttp::Request::Builder.new
        request.url(base_url)

        configuration[:headers].each do |key, value|
          request.header(key, value)
        end

        case configuration[:method]
        when :get
          request.get
        when :post
          media_type = Com::Squareup::Okhttp::MediaType.parse("application/json; charset=utf-8")
          json = JSON.to_json(configuration[:body])
          body = create_request_body(media_type, json)
          request.post(body)
        end

        server_response = execute_request(@client, request.build)

        if(!server_response.nil?)
          response = ResponseProxy.build_response(server_response)
        else
          response = ResponseProxy.network_error_response
        end

        Task.main do
          callback.call(response)
        end
      end
    end

    private
    def set_defaults
      configuration[:headers] = {
        'User-Agent' => Config.user_agent,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      configuration[:method] = :get 
      configuration[:body] = ""
      configuration[:connect_timeout] = Config.connect_timeout
      configuration[:read_timeout] = Config.read_timeout
    end

    def configure
      if session
        configuration[:headers].merge!(session.headers)
        if session.authorization
          configuration[:headers].merge!({'Authorization' => session.authorization.to_s})
        end
      end
      configuration.merge!(@options)
    end
    
  end
end
