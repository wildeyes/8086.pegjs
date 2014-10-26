require('es5-shim')
require('es6-shim')
require('./../shim/array-contains-shim.js')
var assert = require('assert')
	, should = require('should')
	, peg = require("pegjs")
    , fs = require("fs")
	, grammar = fs.readFileSync("./src/8086.pegjs").toString()
    , parser = peg.buildParser(grammar, {startRule:"out", allowedStartRules: ["out","memoryAddress"]})
    , a = function() {
    	return parser.parse.apply(parser, arguments).map(function(str) { 
    		return str.toUpperCase(); 
    	}).join("");
    }

// Fix for parser obj not really being available within PegJS Actions
global.getParse = function getPEGjsParse() {
    return function(toParse, startRule) {
    	return parser.parse(toParse, {startRule:startRule});
    }
}

describe('PEGjs 8086 Assembler', function(){
  describe('#MOV', function(){
    it('should compile test instructions', function(){
		var code = {
			"B442":         "mov ah,0x42",
			"B042":         "mov al,0x42",
			"B342":         "mov bl,0x42",
			"B542":         "mov ch,0x42",
			"B142":         "mov cl,0x42",
			"B742":         "mov bh,0x42",
			"B642":         "mov dh,0x42",
			"B242":         "mov dl,0x42",
			"BD3713":       "mov bp,0x1337",
			"BB3713":       "mov bx,0x1337",
			"B93713":       "mov cx,0x1337",
			"BF3713":       "mov di,0x1337",
			"BA3713":       "mov dx,0x1337",
			"BE3713":       "mov si,0x1337",
			"BC3713":       "mov sp,0x1337",
			"B83713":       "mov ax,0x1337",
			"A03713":       "mov al,[0x1337]",
			"8A07":         "mov al,[bx]",
			"A13713":       "mov ax,[0x1337]",
			"A23713":       "mov [0x1337],al",
			"A33713":       "mov [0x1337],ax",
			"8C1E3713":     "mov [0x1337],ds",
			"8E1E3713":     "mov ds,[0x1337]",
			"8A1E3713":     "mov bl,[0x1337]",
			"881E3713":     "mov [0x1337],bl",
			"891E3713":     "mov [0x1337],bx",
			"8B1E3713":     "mov bx,[0x1337]",
			"C606371342":   "mov byte [0x1337],0x42",
			"C70637133713": "mov word [0x1337],0x1337",
			"C606371342":   "mov byte [0x1337],0x42",
			"C70637133713": "mov word [0x1337],0x1337",
		}
		for(testMachineCode in code) {
			var asm = code[testMachineCode]
				, genMachineCode = a(asm)
			genMachineCode.should.be.equal(testMachineCode)
		}
    })
  })
})