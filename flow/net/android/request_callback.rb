module Net
	class RequestCallback
		def initialize(&callback)
			@callback = callback
		end

		def onResponse(response)
			@callback.call(ResponseProxy.build_response(response))
	    end

	    def onFailure(request, e)
	      puts e.getMessage
	    end
	end
end