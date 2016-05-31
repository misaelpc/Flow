public com.squareup.okhttp.RequestBody create_request_body(com.squareup.okhttp.MediaType mediaType, java.lang.String body){
    return com.squareup.okhttp.RequestBody.create((com.squareup.okhttp.MediaType)mediaType,(java.lang.String)body);
}

public com.squareup.okhttp.Response execute_request(com.squareup.okhttp.OkHttpClient client, com.squareup.okhttp.Request request){
	com.squareup.okhttp.Response response = null;
	try{
		response = client.newCall(request).execute();
	}catch(java.lang.Exception e){
		e.printStackTrace();
	}

	return response;
}