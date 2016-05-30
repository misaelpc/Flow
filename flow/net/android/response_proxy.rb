module Net
  class ResponseProxy
    def self.build_response(okhttp_response)
      self.new(okhttp_response).response
    end

    def initialize(okhttp_response)
      @response = okhttp_response
    end

    def response
      Response.new({
        status_code: status_code,
        status_message: @response.message,
        headers: headers, 
        body: build_body
      })
    end

    private

    def mime_type
      "#{@response.body.contentType.type} - #{@response.body.contentType.subtype}"
    end

    def status_code
      @response.code
    end

    def json?
      @response.body.contentType.subtype == "json"
    end

    def build_body
      body = ""
      begin
        body = parse_response(@response.body.charStream)
      rescue Exception => e
        puts e.message
      end
      body
    end

    def parse_response(stream)
        scanner = Java::Util::Scanner.new(stream)
        scanner.useDelimiter "\\A"
        response_string = scanner.next
        JSON.load(response_string)
    end

    def headers
      headers = Array.new(@response.headers.size)
      (0..headers.size).each do |i|
        headers.push(@response.headers.get(i))
      end
    end
  end
end
