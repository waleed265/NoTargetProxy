function checkVerb() {	
	var verb = context.getVariable("request.verb");
	//print("checkverb method: "+verb);
	//return checkVerbInternal(verb);
	if (verb == "POST") {
		return "POST";
	}
}

function setVerb() {
	var verb = context.setVariable("request.verb");
		//print("checkverb method: "+verb);
			//return checkVerbInternal(verb);
	if (verb == "POST")        
     {
		return "POST";
	}

}