     if (context.getVariable("request.header.Access-Control-Request-Headers.values.count") > 0)
	{
		var headersCollectionStr = context.getVariable("request.header.Access-Control-Request-Headers.values")+'';
		// comes back as "[header1, header2, header3]", so need to strip square brackets
		context.setVariable("reqHeaders", headersCollectionStr.substring(1, headersCollectionStr.length-1));
	}
	
	