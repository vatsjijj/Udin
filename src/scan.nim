import std/[strutils], util

type
  Token* = enum
    atom,
    num,
    str,
    newline,
    colon,
    comma,
    dot,
    gt, lt,
    plus, minus,
    fslash, star,
    equ, equequ,
    lparen, rparen,
    lbrace, rbrace,
    lbrack, rbrack,
    rarrow,
    fun,
    putln,
    ret,
    imprt,
    frm,
    class,
    init,
    mrepr,
    meq,
    this,
    whle,
    cfor,
    cin,
    btrue,
    bfalse,
    cif,
    celse,
    celif,
    cand,
    cor,
    cnot,
    ilgl

var
  ip*: int = 0
  rawTok*: seq[char] = @[]
  tok*: string = ""
  tokenTable*: seq[(Token, string)]
  indentLevel: int = 0

proc atEnd(src: seq[char]): bool =
  if ip == len(src) - 1:
    return true
  else:
    return false

proc keyword(word: string): (Token, string) =
  case word
  of "fun": return (Token.fun, tok)
  of "putln": return (Token.putln, tok)
  of "ret": return (Token.ret, tok)
  of "while": return (Token.whle, tok)
  of "for": return (Token.cfor, tok)
  of "true": return (Token.btrue, tok)
  of "false": return (Token.bfalse, tok)
  of "if": return (Token.cif, tok)
  of "else": return (Token.celse, tok)
  of "elif": return (Token.celif, tok)
  of "import": return (Token.imprt, tok)
  of "from": return (Token.frm, tok)
  of "in": return (Token.cin, tok)
  of "class": return (Token.class, tok)
  of "init": return (Token.init, tok)
  of "this": return (Token.this, tok)
  of "repr": return (Token.mrepr, tok)
  of "eq": return (Token.meq, tok)
  else: return (Token.atom, tok)

proc alpha(src: seq[char]): (Token, string) =
  while isAlphaAscii(src[ip]):
    rawTok.add(src[ip])
    if src[ip + 1] == '_':
      inc ip
      rawTok.add(src[ip])
    if not atEnd(src):
      inc ip
    if atEnd(src):
      break
  tok = toString(rawTok)
  return keyword(tok)

proc digit(src: seq[char]): (Token, string) =
  while isDigit(src[ip]):
    rawTok.add(src[ip])
    if src[ip + 1] == '.':
      inc ip
      rawTok.add(src[ip])
    if not atEnd(src):
      inc ip
    if atEnd(src):
      break
  tok = toString(rawTok)
  return (Token.num, tok)

proc lexStr(src: seq[char]): (Token, string) =
  rawTok = @[]
  if not atEnd(src):
    inc ip
  while src[ip] != '"':
    rawTok.add(src[ip])
    if not atEnd(src):
      inc ip
    if atEnd(src):
      error("Non-terminated string.")
      break
  tok = toString(rawTok)
  return (Token.str, tok)

proc symbol(src: seq[char]): (Token, string) =
  case src[ip]
  of '#':
    while src[ip] != '\n' and not atEnd(src):
      inc ip
    discard
  of '(': return (Token.lparen, "(")
  of ')': return (Token.rparen, ")")
  of '"': return lexStr(src)
  of ':': return (Token.colon, ":")
  of '{': return (Token.lbrace, "{")
  of '}': return (Token.rbrace, "}")
  of '[': return (Token.lbrack, "[")
  of ']': return (Token.rbrack, "]")
  of ',': return (Token.comma, ",")
  of '+': return (Token.plus, "+")
  of '-':
    if src[ip + 1] == '>':
      inc ip
      return (Token.rarrow, "->")
    else:
      return (Token.minus, "-")
  of '/': return (Token.fslash, "/")
  of '*': return (Token.star, "*")
  of '=':
    if src[ip + 1] == '=':
      inc ip
      return (Token.equequ, "==")
    else:
      return (Token.equ, "=")
  of '<': return (Token.lt, "<")
  of '>': return (Token.gt, ">")
  of '&':
    if src[ip + 1] == '&':
      inc ip
      return (Token.cand, "&&")
    else:
      error("Unknown operator '&'")
  of '|':
    if src[ip + 1] == '|':
      inc ip
      return (Token.cor, "||")
    else:
      error("Unknown operator '|'")
  of '!': return (Token.cnot, "!")
  of '.': return (Token.dot, ".")
  else: return (Token.ilgl, "ilgl")

proc scan*(src: seq[char]) =
  while ip < len(src) - 1:
    if isAlphaAscii(src[ip]):
      rawTok = @[]
      tokenTable.add(alpha(src))
    elif isDigit(src[ip]):
      rawTok = @[]
      tokenTable.add(digit(src))
    elif isSpaceAscii(src[ip]):
      rawTok = @[]
      if src[ip] == '\n':
        tokenTable.add((newline, "nl"))
      inc ip
    else:
      rawTok = @[]
      tokenTable.add(symbol(src))
      inc ip

proc transpile*(tbl: seq[(Token, string)] = tokenTable): string =
  var output: string = ""
  for i in 0..len(tbl) - 1:
    case tbl[i][0]
    of Token.putln: output = output & "print"
    of Token.fun: output = output & "def "
    of Token.ret: output = output & "return "
    of Token.whle: output = output & "while "
    of Token.cfor: output = output & "for "
    of Token.cin: output = output & " in "
    of Token.class: output = output & "class "
    of Token.init: output = output & "__init__"
    of Token.mrepr: output = output & "__repr__"
    of Token.meq: output = output & "__eq__"
    of Token.this: output = output & "self"
    of Token.imprt:
      if tbl[i - 1][0] == Token.atom:
        output = output & " import "
      else:
        output = output & "import "
    of Token.frm: output = output & "from "
    of Token.btrue: output = output & "True"
    of Token.bfalse: output = output & "False"
    of Token.cif: output = output & "if "
    of Token.celse: output = output & "else"
    of Token.celif: output = output & "elif "
    of Token.cand: output = output & " and "
    of Token.cor: output = output & " or "
    of Token.lparen: output = output & "("
    of Token.rparen: output = output & ")"
    of Token.lbrack: output = output & "["
    of Token.rbrack: output = output & "]"
    of Token.atom: output = output & tbl[i][1]
    of Token.num: output = output & tbl[i][1]
    of Token.str: output = output & "\"" & tbl[i][1] & "\""
    of Token.colon: output = output & ": "
    of Token.comma: output = output & ", "
    of Token.plus: output = output & " + "
    of Token.minus: output = output & " - "
    of Token.fslash: output = output & " / "
    of Token.star:
      if tbl[i - 1][0] == Token.imprt:
        output = output & "*"
      else:
        output = output & " * "
    of Token.rarrow: output = output & " -> "
    of Token.equ: output = output & " = "
    of Token.equequ: output = output & " == "
    of Token.lt: output = output & " < "
    of Token.gt: output = output & " > "
    of Token.cnot: output = output & " not "
    of Token.dot: output = output & "."
    of Token.lbrace:
      output = output & ":"
      indentLevel = indentLevel + 2
    of Token.rbrace:
      output = output
      indentLevel = indentLevel - 2
    of Token.newline: output = output & "\n" & repeat(' ', indentLevel)
    else: error("'" & tok & "' is not defined or is defined elsewhere")
  return output