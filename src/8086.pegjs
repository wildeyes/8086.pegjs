{
    var symbolTable = {};
    var ilc = 0;
    var opcodeTable = {
        'MOV AH,immediateByte':  {code: 0xB4, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV AL,immediateByte':  {code: 0xB0, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV BL,immediateByte':  {code: 0xB3, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV CH,immediateByte':  {code: 0xB5, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV CL,immediateByte':  {code: 0xB1, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV BH,immediateByte':  {code: 0xB7, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV DH,immediateByte':  {code: 0xB6, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV DL,immediateByte':  {code: 0xB2, ads:['i0'], dataType:BYTE, size:[2]},
        'MOV BP,immediateWord':  {code: 0xBD, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV BX,immediateWord':  {code: 0xBB, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV CX,immediateWord':  {code: 0xB9, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV DI,immediateWord':  {code: 0xBF, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV DX,immediateWord':  {code: 0xBA, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV SI,immediateWord':  {code: 0xBE, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV SP,immediateWord':  {code: 0xBC, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV AX,immediateWord':  {code: 0xB8, ads:['i0', 'i1'], dataType:WORD, size:[3]},
        'MOV AL,directAddress': {code: 0xA0, ads:['d0', 'd1'], dataType:BYTE, size:[3]},
        'MOV AX,directAddress': {code: 0xA1, ads:['d0', 'd1'], dataType:WORD, size:[3]},
        'MOV directAddress,AL': {code: 0xA2, ads:['d0', 'd1'], dataType:BYTE, size:[3]},
        'MOV directAddress,AX': {code: 0xA3, ads:['d0', 'd1'], dataType:WORD, size:[3]},
        'MOV regOrMemWord,segmentRegister': {code: 0x8C, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV segmentRegister,regOrMemWord': {code: 0x8E, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV registerByte,regOrMemByte': {code: 0x8A, ads:['mr', 'd0', 'd1'], dataType:BYTE, size:[2,4]},
        'MOV regOrMemByte,registerByte': {code: 0x88, ads:['mr', 'd0', 'd1'], dataType:BYTE, size:[2,4]},
        'MOV regOrMemWord,registerWord': {code: 0x89, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV registerWord,regOrMemWord': {code: 0x8B, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV regOrMemByte,immediateByte': {code: 0xC6, ads:['mr', 'd0', 'd1', 'i0'], dataType:BYTE, size:[3,5]},
        'MOV regOrMemWord,immediateWord': {code: 0xC7, ads:['mr', 'd0', 'd1', 'i0', 'i1'], dataType:WORD, size:[4,6]}
    }
    // var parse = getParse()
    var parse = function getPEGjsParse() {
        return function(toParse, startRule) {
            return parser.parse(toParse, {startRule:startRule});
        }
    }

    var constantCounter = 0
    	, BYTE = constantCounter++
        , WORD = constantCounter++
        , IMV = constantCounter++
        , REG = constantCounter++
        , SREG = constantCounter++
        , MEM = constantCounter++

        , AL = { type:REG, size: BYTE, data:'AL'}
        , AH = { type:REG, size: BYTE, data:'AH'}
        , BL = { type:REG, size: BYTE, data:'BL'}
        , BH = { type:REG, size: BYTE, data:'BH'}
        , CL = { type:REG, size: BYTE, data:'CL'}
        , CH = { type:REG, size: BYTE, data:'CH'}
        , DL = { type:REG, size: BYTE, data:'DL'}
        , DH = { type:REG, size: BYTE, data:'DH'}
        
        , AX = { type:REG, size: WORD, data:'AX'}
        , BX = { type:REG, size: WORD, data:'BX'}
        , CX = { type:REG, size: WORD, data:'CX'}
        , DX = { type:REG, size: WORD, data:'DX'}

        , SI = { type:REG, size: WORD, data:'SI'}
        , DI = { type:REG, size: WORD, data:'DI'}
        , BP = { type:REG, size: WORD, data:'BP'}
        , SP = { type:REG, size: WORD, data:'SP'}

        , SS = { type:REG, size: WORD, data:'SS'}
        , CS = { type:REG, size: WORD, data:'CS'}
        , DS = { type:REG, size: WORD, data:'DS'}
        , ES = { type:REG, size: WORD, data:'ES'}
        , byteRegisters = [AL, AH, BL, BH, CL, CH, DL, DH]
        , wordRegisters = [AX, BX, CX, DX]

        , getByteReg = function (n) { return byteRegisters.find(function (reg) { return reg.data === n}); }
        , getWordReg = function (n) { return wordRegisters.find(function (reg) { return reg.data === n}); }

        // , segmentRegisters = [SS, CS, DS, ES]
        , memoryAddress = function (n) { return { type:MEM,data: n}; } //memory addresses aint no having sizes
		, directAddress = memoryAddress
		, segmentRegister = function (n) { return { type:SREG, size:BYTE, data: n}; }
        , immediateByte = function (n) { return { type:IMV, size:BYTE, data: n}; }
        , immediateWord = function (n) { return { type:IMV, size:WORD, data: n}; }
        , regOrMemByte = function (n) { return parse(n,"memoryAddress") ? memoryAddress(n) : getByteReg(n); }
        , regOrMemWord = function (n) { return parse(n,"memoryAddress") ? memoryAddress(n) : getWordReg(n); }
		, registerByte = function (n) { return { type: getByteReg(n), size:BYTE, data: n}; }
		, registerWord = function (n) { return { type: getWordReg(n), size:BYTE, data: n}; }

        , mrTypes = [
	        "immediateByte",
	        "immediateWord",
	        "regOrMemByte",
	        "regOrMemWord",
	        "segmentRegister",
	        "registerByte",
	        "registerWord"]

    var twosComplement = function (d8) {
        return (0xFF + d8 + 1);
    };
}

out = asm:assemblyCode {
    return asm.filter(function(n) { return n ? n : false; }).map(function(n) { return n.toString(16); });
}

assemblyCode = __ first:line rest:(eol l:line {return l})* { return first.concat(rest); }

line = whitespace* label:labelPart? op:operation? whitespace* comment:comment? {
    if (label !== '') {
        symbolTable[label] = ilc; 
    } 
    if(op == null || op == undefined) {
        return [];
    }
    ilc += op.size;
    return op.opcodes;
}

labelPart = label:label ':' whitespace* {return label;}
label = first:[a-zA-Z?@] rest:([a-zA-Z0-9]*) {return first + rest.join('');}

operation = op:(op_mov) {
    var opData = opcodeTable[op.mnemonic]
     ? opcodeTable[op.mnemonic]
      : expected('Instruction Mnemonic, received Unknown;' + op.mnemonic)
        , arrSize = opData.size
        , size = arrSize[0]
        , ads = opData.ads
        , opcode = opData.code
        , arrOperandTypes = op.mnemonic.split(" ")[1].split(",")
        , mr = (mrTypes.contains(arrOperandTypes[0]) && mrTypes.contains(arrOperandTypes[0]))
        ? expected("ModRM bit not implemented") : []
        , extraOpcodes = [op.leftOperand,op.rightOperand].map(function (operand) {
 	        if(operand.type === IMV)
                if (operand.size === WORD)
	            	return [(operand.data & 0x00FF), ((operand.data & 0xFF00) / 0x100)]
                else
                    return [operand.data]
            else if(operand.type === MEM)
                return [(operand.data & 0x00FF), ((operand.data & 0xFF00) / 0x100)]
            else
                return []
        }).reduce(function(prev,current) { return prev.concat(current); })
        , opcodes = [opcode].concat(mr, extraOpcodes)
    console.log(opcodes, op.leftOperand, op.rightOperand)

    return {
        opcodes: opcodes,
        /* data: data,*/
        size: size
    };
}

op_mov  = ins:([mM][oO][vV]) whitespace+ data:(
    ([Aa][Hh] [,] whitespace* a1:immediateByte { return ['MOV AH,immediateByte', AH, immediateByte(a1)]  }) /
    ([Aa][Ll] [,] whitespace* a1:immediateByte { return ['MOV AL,immediateByte', AL, immediateByte(a1)]  }) /
    ([Aa][Xx] [,] whitespace* a1:immediateWord { return ['MOV AX,immediateWord', AX, immediateWord(a1)]  }) /
    ([Bb][Hh] [,] whitespace* a1:immediateByte { return ['MOV BH,immediateByte', BH, immediateByte(a1)]  }) /
    ([Bb][Ll] [,] whitespace* a1:immediateByte { return ['MOV BL,immediateByte', BL, immediateByte(a1)]  }) /
    ([Bb][Pp] [,] whitespace* a1:immediateWord { return ['MOV BP,immediateWord', BP, immediateWord(a1)]  }) /
    ([Bb][Xx] [,] whitespace* a1:immediateWord { return ['MOV BX,immediateWord', BX, immediateWord(a1)]  }) /
    ([Cc][Hh] [,] whitespace* a1:immediateByte { return ['MOV CH,immediateByte', CH, immediateByte(a1)]  }) /
    ([Cc][Ll] [,] whitespace* a1:immediateByte { return ['MOV CL,immediateByte', CL, immediateByte(a1)]  }) /
    ([Cc][Xx] [,] whitespace* a1:immediateWord { return ['MOV CX,immediateWord', CX, immediateWord(a1)]  }) /
    ([Dd][Hh] [,] whitespace* a1:immediateByte { return ['MOV DH,immediateByte', DH, immediateByte(a1)]  }) /
    ([Dd][Ii] [,] whitespace* a1:immediateWord { return ['MOV DI,immediateWord', DI, immediateWord(a1)]  }) /
    ([Dd][Ll] [,] whitespace* a1:immediateByte { return ['MOV DL,immediateByte', DL, immediateByte(a1)]  }) /
    ([Dd][Xx] [,] whitespace* a1:immediateWord { return ['MOV DX,immediateWord', DX, immediateWord(a1)]  }) /
    ([Ss][Ii] [,] whitespace* a1:immediateWord { return ['MOV SI,immediateWord', SI, immediateWord(a1)]  }) /
    ([Ss][Pp] [,] whitespace* a1:immediateWord { return ['MOV SP,immediateWord', SP, immediateWord(a1)]  }) /
    ([Aa][Ll] [,] whitespace* a1:directAddress { return  ['MOV AL,directAddress' , AL, directAddress(a1)]  }) /
    ([Aa][Xx] [,] whitespace* a1:directAddress { return  ['MOV AX,directAddress' , AX, directAddress(a1)]  }) /
    (a0:directAddress [,] whitespace* a1:[Aa][Xx] { return ['MOV directAddress,AX', directAddress(a0), AX]  }) /
    (a0:directAddress [,] whitespace* a1:[Aa][Ll] { return ['MOV directAddress,AL', directAddress(a0), AL]  }) /
    (a0:registerByte [,] whitespace* a1:regOrMemByte { return ['MOV registerByte,regOrMemByte', registerByte(a0), regOrMemByte(a1)]  }) /
    (a0:registerWord [,] whitespace* a1:regOrMemWord { return ['MOV registerWord,regOrMemWord', registerWord(a0), regOrMemWord(a1)]  }) /
    (a0:regOrMemByte [,] whitespace* a1:registerByte { return ['MOV regOrMemByte,registerByte', regOrMemByte(a0), registerByte(a1)]  }) /
    (a0:regOrMemWord [,] whitespace* a1:registerWord { return ['MOV regOrMemWord,registerWord', regOrMemWord(a0), registerWord(a1)]  }) /
    (a0:regOrMemWord [,] whitespace* a1:immediateWord { return ['MOV regOrMemWord,immediateWord', regOrMemWord(a0), immediateWord(a1)]  }) /
    (a0:regOrMemByte [,] whitespace* a1:immediateByte { return ['MOV regOrMemByte,immediateByte', regOrMemByte(a0), immediateByte(a1)]  }) /
    (a0:regOrMemWord [,] whitespace* a1:segmentRegister { return ['MOV regOrMemWord,segmentRegister', regOrMemWord(a0), segmentRegister(a1)]  }) /
    (a0:segmentRegister [,] whitespace* a1:regOrMemWord { return ['MOV segmentRegister,regOrMemWord', segmentRegister(a0), regOrMemWord(a1)]  }) /
    (unparsed:([a-zA-Z0-9,] / whitespace)+ { expected('OP_MOV: valid ' + ins + ' instruction, Got: ' + unparsed.join(''));})
) { return {name:ins.join('').toUpperCase(), mnemonic: data[0], leftOperand: data[1], rightOperand: data[2]}}

/* OPEARTORS */

/*TODO: Add Human Readable names to everything*/

comment 'comment' = ';' c:[^\n\r\n\u2028\u2029]* {return c.join('');}
__ = (whitespace / eol )*
eol 'line end' = '\n' / '\r\n' / '\r' / '\u2028' / '\u2029'
whitespace 'whitespace' = [ \t\v\f\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]

byteRegister 'Byte General Registers' = reg:([a-dA-D][hlHL]) { return reg.join('').toUpperCase(); }
generalRegister 'Word General Registers' = reg:([a-dA-D][Xx]) { return reg.join('').toUpperCase(); }
indexRegister = reg:([sdbSDB][IPip]) { return reg.join('').toUpperCase(); }
segmentRegister = reg:([cdesCDES][Ss]) { return reg.join('').toUpperCase(); }
SIorDIRegister = reg:([SD][Ii]) { return reg.join('').toUpperCase(); }
BXorBPRegister = reg:([Bb][XPxp]) { return reg.join('').toUpperCase(); }
addressRegister = SIorDIRegister / BXorBPRegister

immediateByte = Byte
immediateWord = Word
registerByte = byteRegister
registerWord = generalRegister / indexRegister
regOrMemWord = memoryAddress / registerWord
regOrMemByte = memoryAddress / registerByte

/* TODO: Support for WORD/BYTE types with (BYTE PTR / BYTE / etc). 
Should be returning {addr:addr,type:sizeType} in future to indicate type.*/
directAddress 'Direct Address' = '[' addr:(numLiteral) ']' { return addr; }
memoryAddress 'Memory Address' = '[' arrAddress:(
    (reg:addressRegister {
        return reg === 'BP'
         ? expected('BP Can\'t used as a single register in memory address (Write BP + 0)') 
         : [reg]}) /
    (i:immediateWord { return [i]}) /
    (i:immediateByte { return [i]}) /
    (equ:Equation {
        var usedType = {'BX,BP':false, 'SI,DI':false, 'immediateValue': false}
        if(equ.length < 2 || equ.length > 3)
            expected('Only 2-3 stuff in memory address')
        for (var i = 0; i < equ.length; i++) {
            if(equ[i].contains('BX') || equ[i].contains('BP'))
                usedType['BX,BP'] ? expected('Can use BX,BP only once in memory address.') : usedType['BX,BP'] = true;
            if(equ[i].contains('SI') || equ[i].contains('DI'))
                usedType['SI,DI'] ? expected('Can use SI,DI only once in memory address.') : usedType['SI,DI'] = true;
            if(parse(equ[i],'numLiteral')) {
                if(usedType['immediateValue'])
                	expected('Can use immediateValue only once in memory address.')
                else 
                	usedType['immediateValue'] = true;
            }
        }
        return equ;
    })) ']' { return arrAddress} 

/* SPECIALS */
Equation = first:(EquPart) rest:(EquPart*) {return first.concat(rest);}
EquPart = op:(addressRegister / numLiteral) sign:[+-]* { return sign ? [op,sign] : [op] }

/* LITERALS */
Byte = n:numLiteral { return n > 0xFF ? expected('8-bit data expected.') : n; }
Word = n:numLiteral { return n > 0xFFFF ? expected('16-bit data expected.') : n; }
numLiteral 'numeric literal' = binLiteral / hexLiteral / decLiteral
decLiteral 'decimal literal' = neg:[-]? digits:digit+ {
    return parseInt((!neg ? '' :'-') + digits.join(''), 10);
}
hexLiteral 'hex literal' = hexForm1 / hexForm2
hexForm1 = '0x' hexits:hexit+ {
    return parseInt(hexits.join(''), 16);
}
hexForm2 = hexits:hexit+ ('H' / 'h') {
    return parseInt(hexits.join(''), 16);
}
binLiteral 'bin literal' = binLiteral1 / binLiteral2
binLiteral1 'binary literal' =
    '0b' bits:bit+ { return parseInt(bits.join(''), 2); }
binLiteral2 'binary literal' =
    bits:bit+ 'b'  { return parseInt(bits.join(''), 2); }

identifier 'identifier' = ltrs:identLetter+ { return ltrs.join(''); }
identLetter 'letter/underscore' = [a-zA-Z_]
digit 'digit' = [0-9]
hexit 'hex digit' = [0-9a-fA-F]
bit 'bit' = [01]