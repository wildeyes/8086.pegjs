/* 
    8086.pegjs by XWILDEYES
    adapted from https://gist.github.com/debjitbis08/5027354
   */
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
        'MOV AL,registerOrMemoryByte': {code: 0xA0, ads:['d0', 'd1'], dataType:BYTE, size:[3]},
        'MOV AX,registerOrMemoryWord': {code: 0xA1, ads:['d0', 'd1'], dataType:WORD, size:[3]},
        'MOV registerOrMemoryByte,AL': {code: 0xA2, ads:['d0', 'd1'], dataType:BYTE, size:[3]},
        'MOV registerOrMemoryWord,AX': {code: 0xA3, ads:['d0', 'd1'], dataType:WORD, size:[3]},
        'MOV registerOrMemoryWord,segmentRegister': {code: 0x8C, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV segmentRegister,registerOrMemoryWord': {code: 0x8E, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV registerByte,registerOrMemoryByte': {code: 0x8A, ads:['mr', 'd0', 'd1'], dataType:BYTE, size:[2,4]},
        'MOV registerOrMemoryByte,registerByte': {code: 0x88, ads:['mr', 'd0', 'd1'], dataType:BYTE, size:[2,4]},
        'MOV registerOrMemoryWord,registerWord': {code: 0x89, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV registerWord,registerOrMemoryWord': {code: 0x8B, ads:['mr', 'd0', 'd1'], dataType:WORD, size:[2,4]},
        'MOV registerOrMemoryByte,immediateByte': {code: 0xC6, ads:['mr', 'd0', 'd1', 'i0'], dataType:BYTE, size:[3,5]},
        'MOV registerOrMemoryWord,immediateWord': {code: 0xC7, ads:['mr', 'd0', 'd1', 'i0', 'i1'], dataType:WORD, size:[4,6]}
    }

    var BYTE = 0
        , WORD = 1
        , IMV = 2
        , REG = 3

        , AL = {type:REG, data:'AL'}
        , AH = {type:REG, data:'AH'}

    var twosComplement = function (d8) {
        return (0xFF + d8 + 1);
    };
}

out = asm:assemblyCode {
    return asm.filter(function(n) { return n ? n : false; }).map(function(n) { return n.toString(16); }).join(' ');
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
    // console.log('Detecting operation...', op)
    var opData = opcodeTable[op.mnemonic]
     ? opcodeTable[op.mnemonic]
      : expected('Instruction Mnemonic, received Unknown;' + op.mnemonic),
        arrSize = opData.size, //[0] = minSize OR size, [1] = maxSize OR undefined
        size = arrSize[0],
        opcodes = [opData.code],
        ads = opData.ads

    for (var i = 0; i < ads.length; i++) {
        var ad = ads[i]

        if(ad === 'i0')
            // if(op.rightOperand > 0xff)
            //     opcodes.push()
            // else
            opcodes.push(op.rightOperand)
    };

    return {
        opcodes: opcodes,
        /* data: data,*/
        size: size
    };
}

pairInstruction = op:(op_mov) {
    return {
        name: op[0],
        params: op[2],
    };
}

op_mov  = ins:([mM][oO][vV]) whitespace+ data:(
    ([Aa][Hh] [,] whitespace* a1:immediateByte { return ['MOV AH,immediateByte','AH',a1]  }) /
    ([Aa][Ll] [,] whitespace* a1:immediateByte { return ['MOV AL,immediateByte','AL',a1]  }) /
    ([Aa][Ll] [,] whitespace* a1:registerOrMemoryByte { return ['MOV AL,registerOrMemoryByte','AL',a1]  }) /
    ([Aa][Xx] [,] whitespace* a1:immediateWord { return ['MOV AX,immediateWord','AX',a1]  }) /
    ([Aa][Xx] [,] whitespace* a1:registerOrMemoryWord { return ['MOV AX,registerOrMemoryWord','AX',a1]  }) /
    ([Bb][Hh] [,] whitespace* a1:immediateByte { return ['MOV BH,immediateByte','BH',a1]  }) /
    ([Bb][Ll] [,] whitespace* a1:immediateByte { return ['MOV BL,immediateByte','BL',a1]  }) /
    ([Bb][Pp] [,] whitespace* a1:immediateWord { return ['MOV BP,immediateWord','BP',a1]  }) /
    ([Bb][Xx] [,] whitespace* a1:immediateWord { return ['MOV BX,immediateWord','BX',a1]  }) /
    ([Cc][Hh] [,] whitespace* a1:immediateByte { return ['MOV CH,immediateByte','CH',a1]  }) /
    ([Cc][Ll] [,] whitespace* a1:immediateByte { return ['MOV CL,immediateByte','CL',a1]  }) /
    ([Cc][Xx] [,] whitespace* a1:immediateWord { return ['MOV CX,immediateWord','CX',a1]  }) /
    ([Dd][Hh] [,] whitespace* a1:immediateByte { return ['MOV DH,immediateByte','DH',a1]  }) /
    ([Dd][Ii] [,] whitespace* a1:immediateWord { return ['MOV DI,immediateWord','DI',a1]  }) /
    ([Dd][Ll] [,] whitespace* a1:immediateByte { return ['MOV DL,immediateByte','DL',a1]  }) /
    ([Dd][Xx] [,] whitespace* a1:immediateWord { return ['MOV DX,immediateWord','DX',a1]  }) /
    ([Ss][Ii] [,] whitespace* a1:immediateWord { return ['MOV SI,immediateWord','SI',a1]  }) /
    ([Ss][Pp] [,] whitespace* a1:immediateWord { return ['MOV SP,immediateWord','SP',a1]  }) /
    (a0:registerByte [,] whitespace* a1:registerOrMemoryByte { return ['MOV registerByte,registerOrMemoryByte',a0,a1]  }) /
    (a0:registerWord [,] whitespace* a1:registerOrMemoryWord { return ['MOV registerWord,registerOrMemoryWord',a0,a1]  }) /
    (a0:segmentRegister [,] whitespace* a1:registerOrMemoryWord { return ['MOV segmentRegister,registerOrMemoryWord',a0,a1]  }) /
    (a0:registerOrMemoryWord [,] whitespace* a1:[Aa][Xx] { return ['MOV registerOrMemoryWord,AX',a0,a1]  }) /
    (a0:registerOrMemoryByte [,] whitespace* a1:[Aa][Ll] { return ['MOV registerOrMemoryByte,AL',a0,a1]  }) /
    (a0:registerOrMemoryByte [,] whitespace* a1:immediateByte { return ['MOV registerOrMemoryByte,immediateByte',a0,a1]  }) /
    (a0:registerOrMemoryByte [,] whitespace* a1:registerByte { return ['MOV registerOrMemoryByte,registerByte',a0,a1]  }) /
    (a0:registerOrMemoryWord [,] whitespace* a1:immediateWord { return ['MOV registerOrMemoryWord,immediateWord',a0,a1]  }) /
    (a0:registerOrMemoryWord [,] whitespace* a1:registerWord { return ['MOV registerOrMemoryWord,registerWord',a0,a1]  }) /
    (a0:registerOrMemoryWord [,] whitespace* a1:segmentRegister { return ['MOV registerOrMemoryWord,segmentRegister',a0,a1]  }) /
    (unparsed:([a-zA-Z0-9,] / whitespace)+ { expected('valid MOV instruction, Got;' + unparsed.join(''));})
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
registerOrMemoryWord = memoryAddress / registerWord
registerOrMemoryByte = memoryAddress / registerByte

/* TODO: Support for WORD/BYTE types with (BYTE PTR / BYTE / etc). 
Should be returning {addr:addr,type:sizeType} in future to indicate type.*/
memoryAddress = '[' arrAddress:(
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
            if(parser.parse(equ[i],'numLiteral'))
                usedType['immediateValue']
                 ? expected('Can use immediateValue only once in memory address.')
                  : usedType['immediateValue'] = true;
        }
        return equ;
    })) ']' { return arrAddress }

/* SPECIALS */
Equation = first:(EquPart) rest:(EquPart*) {return first.concat(rest);}
EquPart = op:(addressRegister / numLiteral) sign:[+-]* { return sign ? [op,sign] : [op] }

/* LITERALS */
Byte = n:numLiteral {
    if (n > 0xFF) 
        expected('8-bit data expected.');
    else
        return n;
}
Word = n:numLiteral {
    if (n > 0xFFFF) 
        expected('16-bit data expected.');
    else
        return n;
}
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