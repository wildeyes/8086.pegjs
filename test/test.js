var assert = require('assert')
	, should = require('should')
	, peg = require("pegjs")
    , fs = require("fs")
	, grammar = fs.readFileSync("./src/8086.pegjs").toString()
    , parser = peg.buildParser(grammar)
    , a = function() {
    	return parser.parse.apply(parser, arguments).toUpperCase();
    }

describe('Parse', function(){
  describe('#MOV', function(){
    it('should correctly parse MOV', function(){

		a("mov ah,0x42").should.containEql("B4")
		a("mov al,0x42").should.containEql("B0")
		a("mov bl,0x42").should.containEql("B3")
		a("mov ch,0x42").should.containEql("B5")
		a("mov cl,0x42").should.containEql("B1")
		a("mov bh,0x42").should.containEql("B7")
		a("mov dh,0x42").should.containEql("B6")
		a("mov dl,0x42").should.containEql("B2")
		a("mov bp,0x1337").should.containEql("BD")
		a("mov bx,0x1337").should.containEql("BB")
		a("mov cx,0x1337").should.containEql("B9")
		a("mov di,0x1337").should.containEql("BF")
		a("mov dx,0x1337").should.containEql("BA")
		a("mov si,0x1337").should.containEql("BE")
		a("mov sp,0x1337").should.containEql("BC")
		a("mov ax,0x1337").should.containEql("B8")
		a("mov al,[0x1337]").should.containEql("A0")
		a("mov ax,[0x1337]").should.containEql("A1")
		a("mov [0x1337],AL").should.containEql("A2")
		a("mov [0x1337],AX").should.containEql("A3")
		a("mov [0x1337],DS").should.containEql("8C")
		a("mov ds,[0x1337]").should.containEql("8E")
		a("mov bl,[0x1337]").should.containEql("8A")
		a("mov [0x1337],BL").should.containEql("88")
		a("mov [0x1337],BX").should.containEql("89")
		a("mov bx,[0x1337]").should.containEql("8B")
		// a("mov byte [0x1337],0x42").should.containEql("C6")
		// a("mov word [0x1337],0x1337").should.containEql("C6")
		// a("mov byte [0x1337],0x42").should.containEql("C7")
		// a("mov word [0x1337],0x1337").should.containEql("C7")

    })
  })
})