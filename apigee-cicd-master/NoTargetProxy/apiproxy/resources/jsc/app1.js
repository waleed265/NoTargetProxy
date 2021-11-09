//app1.js

function checkIsMandatory(paramName, paramValue) {
    if(paramValue === null || paramValue === "") {
        context.setVariable("InvalidRequest", true);
        context.setVariable("ValidationError", paramName + " is mandatory.");
        context.setVariable("ErrorCode","02");
        return false;
    }
}

function checkMaxLength(paramName, paramValue, maxLimit) {
    if (paramValue === null || paramValue === "") {
        return;
    }
    if(paramValue.length > maxLimit){
        context.setVariable("InvalidRequest", true);
        context.setVariable("ValidationError", paramName + " Maximum length is " + maxLimit + " characters ");
        context.setVariable("ErrorCode","03");
        return false; 
    }
}

function checkRegx(paramName, paramValue, type) {
    if (paramValue === null || paramValue === ("")) {
        return;
    }
    if (type === 'N') {
            var regex = /^[0-9]+$/;
            if(regex.test(paramValue) === false){
            context.setVariable("InvalidRequest",true);
            context.setVariable("ValidationError", paramName + " should be in digits");
            context.setVariable("ErrorCode","04");
            return false; 
           }
    }
    else if (type === 'AN') {
         var regex = /^[a-zA-Z0-9]+$/;
        if(regex.test(paramValue) === false){
            context.setVariable("InvalidRequest",true);
            context.setVariable("ValidationError", paramName + " - Special Characters are not allowed.");
            context.setVariable("ErrorCode","04");
            return false; 
         }
    }
    else if (type === "Email" ) {
        var regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if(regex.test(paramValue) === false){
            context.setVariable("InvalidRequest",true);
            context.setVariable("ValidationError", "Invalid "+ paramName);
            context.setVariable("ErrorCode","04");
            return false; 
        }
    }
    else if (type === "MobileNo") {
          var regex = /^(923)[0-9]{9}$/;
          if(paramValue === null || regex.test(paramValue) === false){
            context.setVariable("InvalidRequest", true);
            context.setVariable("ValidationError","Invalid "+ paramName);
            context.setVariable("ErrorCode","04");
            return false;
          }
    }
}