// test.js

var expect = require('expect.js');
var sinon = require('sinon');
var rewire = require('rewire');
var app = rewire('../../NoTargetProxy/apiproxy/resources/jsc/app.js');	//Target javascript file to be tested

var fakeContext = {							//declaring fake contexts
  getVariable: function(s) {},
  setVariable: function(s) {}
};

var contextGetVariableMethod;
var contextSetVariableMethod;
																		//stubbing all Apigee objects and the methods we need
beforeEach(function () {												//This method will execute before every it() method in the test
  contextGetVariableMethod = sinon.stub(fakeContext, 'getVariable');	
  contextSetVariableMethod = sinon.stub(fakeContext, 'setVariable');	
});

afterEach(function() {						//restore all stubbed methods back to their original implementation
  contextGetVariableMethod.restore();
  contextSetVariableMethod.restore();
});

describe('feature: check & set Verb', function() {

  it('should have POST', function() {
    contextGetVariableMethod.withArgs('request.verb').returns("POST");
    app.__set__('context', fakeContext);								//Setting Fake Contexts

    var checkVerb = app.__get__('checkVerb');
    expect(checkVerb()).to.equal("POST");								//Final Assertion on mocked function response
  });

  it('should set POST', function() {
    contextSetVariableMethod.withArgs('request.verb').returns("POST");
    app.__set__('context', fakeContext);

    var setVerb = app.__get__('setVerb');
    expect(setVerb()).to.equal("POST");
  });

/*it('should fail a test on error', function(done) {
		throw new Error('This test should fail!');
	});

 it('should have POST', function() {
    contextGetVariableMethod.withArgs('request.verb').returns("POST");
    app.__set__('context', fakeContext);

    var checkVerb = app.__get__('checkVerb');
    expect(checkVerb()).to.equal("GET");
  });*/
});