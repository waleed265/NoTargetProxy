var grant_type = context.getVariable("request.queryparam.grant_type");
var Authorization = context.getVariable("request.header.Authorization");
      
var isError = false;

  if(grant_type === "" || grant_type === null || grant_type !== "client_credentials")
  {
      isError = true;
      context.setVariable("resultCode" , "999998");
      context.setVariable("resultDesc" , "Required parameter [grant_type] is invalid or empty");
  }
  else if (Authorization === "" || Authorization === null)
  {
      isError = true;
      context.setVariable("resultCode" , "999997");
      context.setVariable("resultDesc" , "Invalid Authorization header");
  }
  
context.setVariable("isError" , isError);
