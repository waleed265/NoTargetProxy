// test.js

var expect = require('expect.js');
var sinon = require('sinon');
var rewire = require('rewire');
var app = rewire('../../NoTargetProxy/apiproxy/resources/jsc/app1.js');

var fakeContext = {
  getVariable: function(s) {},
  setVariable: function(s) {}
};

var contextGetVariableMethod;
var contextSetVariableMethod;

beforeEach(function () {
  contextGetVariableMethod = sinon.stub(fakeContext, 'getVariable');
  contextSetVariableMethod = sinon.stub(fakeContext, 'setVariable');
});

afterEach(function() {
  contextGetVariableMethod.restore();
  contextSetVariableMethod.restore();
});

describe('feature: check & set Verb', function() {
//-------Unit test for function checkIsMandatory(paramName, paramValue)--------------------//
  it('should checkIsMandatory', function() {
    //contextSetVariableMethod.withArgs('request.verb').returns("F");
    app.__set__('context', fakeContext);
    var checkIsMandatory = app.__get__('checkIsMandatory');
    expect(checkIsMandatory(null, null)).to.equal(false);
  });

//------Unit test for checkMaxLength(paramName, paramValue, maxLimit)-----------//

  it('should checkMaxLength', function() {
    app.__set__('context', fakeContext);
    var checkMaxLength = app.__get__('checkMaxLength');
    expect(checkMaxLength(null, null, 10)).to.equal(undefined);
  });

  it('should checkMaxLength', function() {
    app.__set__('context', fakeContext);
    var checkMaxLength = app.__get__('checkMaxLength');
    expect(checkMaxLength("sasa", "ggg", 1)).to.equal(false);
  });

//-------Unit test for function checkRegx(paramName, paramValue, type)----------//
//-------For 1st condition--------
  it('should checkRegx', function() {
    app.__set__('context', fakeContext);
    var checkRegx = app.__get__('checkRegx');
    expect(checkRegx(null, null)).to.equal(undefined);
  });
//-------For 2nd condition--------
  it('should checkRegx1', function() {
    app.__set__('context', fakeContext);
    var checkRegx = app.__get__('checkRegx');
    expect(checkRegx("sas","/hdjd",'N')).to.equal(false);
    
  });
//-------For 3rd condition--------  
  it('should checkRegx2', function() {
    app.__set__('context', fakeContext);
    var checkRegx = app.__get__('checkRegx');
    expect(checkRegx("sas","/dassaDS12",'AN')).to.equal(false);
    
  });
//-------For 4th condition--------  
    it('should checkRegx3', function() {
    app.__set__('context', fakeContext);
    var checkRegx = app.__get__('checkRegx');
    expect(checkRegx("sas","hdjd",'Email')).to.equal(false);    
  });
//-------For 5th condition--------  
    it('should checkRegx4', function() {
    app.__set__('context', fakeContext);
    var checkRegx = app.__get__('checkRegx');
    expect(checkRegx("sas","/923219488113",'MobileNo')).to.equal(false);
    
  });
});