import std/[strutils], util

type
  Token* = enum
    atom,
    num,
    str,
    newline,
    colon,
    semicolon,
    comma,
    dot, dotdot,
    gt, lt,
    gteq, lteq,
    plus, minus,
    fslash, star, floordiv,
    omod,
    pipe,
    equ, equequ,
    lparen, rparen,
    lbrace, rbrace,
    lbrack, rbrack,
    rarrow,
    fun,
    put,
    ret,
    cont,
    imprt,
    frm,
    class,
    init,
    mrepr,
    meq,
    madd,
    nothing,
    this,
    whle,
    cse,
    cof,
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
    noteq,
    ilgl

var
  ip*: int = 0
  rawTok*: seq[char] = @[]
  tok*: string = ""
  tokenTable*: seq[(Token, string)]
  indentLevel: int = 0
  line: int = 1
  lhs, rhs: string

proc atEnd(src: seq[char]): bool =
  if ip == len(src) - 1:
    return true
  else:
    return false

proc lookahead(tbl: seq[(Token, string)], expect: Token, index: int): bool =
  if tbl[index + 1][0] == expect:
    return true
  else:
    return false

proc lookback(tbl: seq[(Token, string)], expect: Token, index: int): bool =
  if tbl[index - 1][0] == expect:
    return true
  else:
    return false

proc keyword(word: string): (Token, string) =
  case word
  of "fun": return (Token.fun, tok)
  of "put": return (Token.put, tok)
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
  of "continue": return (Token.cont, tok)
  of "nothing": return (Token.nothing, tok)
  of "add": return (Token.madd, tok)
  of "case": return (Token.cse, tok)
  of "of": return (Token.cof, tok)
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
    if src[ip + 1] == '.' and not (src[ip + 2] == '.'):
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
  of ';': return (Token.semicolon, ";")
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
  of '/':
    if src[ip + 1] == '/':
      return (Token.floordiv, "//")
    else:
      return (Token.fslash, "/")
  of '*': return (Token.star, "*")
  of '%': return (Token.omod, "%")
  of '=':
    if src[ip + 1] == '=':
      inc ip
      return (Token.equequ, "==")
    else:
      return (Token.equ, "=")
  of '<':
    if src[ip + 1] == '=':
      inc ip
      return (Token.lteq, "<=")
    else:
      return (Token.lt, "<")
  of '>':
    if src[ip + 1] == '=':
      inc ip
      return (Token.gteq, ">=")
    else:
      return (Token.gt, ">")
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
      return (Token.pipe, "|")
  of '!':
    if src[ip + 1] == '=':
      inc ip
      return (Token.noteq, "!=")
    else:
      return (Token.cnot, "!")
  of '.':
    if src[ip + 1] == '.':
      inc ip
      return (Token.dotdot, "..")
    else:
      return (Token.dot, ".")
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
  var output: string = "# Generated by Udin 0.1.5\n\n"
  for i in 0..len(tbl) - 1:
    case tbl[i][0]
    of Token.cse:
      if lookahead(tbl, Token.atom, i):
        output = output & "match "
      else:
        error("Line " & $line & ": Expected an atom after case.")
    of Token.cof: output = output & "case "
    of Token.put:
      if lookahead(tbl, Token.lparen, i):
        output = output & "print"
      else:
        error("Line " & $line & ": Expected a parenthese after print statement.")
    of Token.fun:
      if lookahead(tbl, Token.atom, i) or lookahead(tbl, Token.init, i) or lookahead(tbl, Token.mrepr, i) or lookahead(tbl, Token.meq, i):
        output = output & "def "
      else:
        error("Line " & $line & ": Expected an atom after function definition.")
    of Token.ret: output = output & "return "
    of Token.cont: output = output & "continue"
    of Token.whle: output = output & "while "
    of Token.cfor:
      if lookahead(tbl, Token.atom, i):
        output = output & "for "
      else:
        error("Line " & $line & ": Expected an atom after for keyword.")
    of Token.cin: output = output & " in "
    of Token.class: output = output & "class "
    of Token.init:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__init__"
      else:
        error("Line " & $line & ": Expected parenthese after init keyword.")
    of Token.mrepr:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__repr__"
      else:
        error("Line " & $line & ": Expected parenthese after repr keyword.")
    of Token.meq:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__eq__"
      else:
        error("Line " & $line & ": Expected parenthese after eq keyword.")
    of Token.this: output = output & "self"
    of Token.imprt:
      if i != 0:
        if lookback(tbl, Token.atom, i):
          output = output & " import "
      else:
        if lookahead(tbl, Token.atom, i):
          output = output & "import "
        else:
          error("Line " & $line & ": Expected a module name after import statement.")
    of Token.frm: output = output & "from "
    of Token.btrue: output = output & "True"
    of Token.bfalse: output = output & "False"
    of Token.nothing: output = output & "pass"
    of Token.madd: output = output & "__add__"
    of Token.cif: output = output & "if "
    of Token.celse: output = output & "else"
    of Token.celif: output = output & "elif "
    of Token.cand: output = output & " and "
    of Token.cor: output = output & " or "
    of Token.lparen: output = output & "("
    of Token.rparen: output = output & ")"
    of Token.lbrack: output = output & "["
    of Token.rbrack: output = output & "]"
    of Token.pipe: output = output & " | "
    of Token.atom: output = output & tbl[i][1]
    of Token.num:
      if lookahead(tbl, Token.dotdot, i):
        continue
      if lookback(tbl, Token.dotdot, i):
        continue
      else:
        output = output & tbl[i][1]
    of Token.str: output = output & "\"" & tbl[i][1] & "\""
    of Token.colon: output = output & ": "
    of Token.semicolon: output = output & "; "
    of Token.comma: output = output & ", "
    of Token.plus: output = output & " + "
    of Token.minus: output = output & " - "
    of Token.fslash: output = output & " / "
    of Token.star:
      if lookback(tbl, Token.imprt, i):
        output = output & "*"
      else:
        output = output & " * "
    of Token.omod: output = output & " % "
    of Token.floordiv: output = output & " // "
    of Token.rarrow: output = output & " -> "
    of Token.equ: output = output & " = "
    of Token.equequ: output = output & " == "
    of Token.lt: output = output & " < "
    of Token.gt: output = output & " > "
    of Token.lteq: output = output & " <= "
    of Token.gteq: output = output & " >= "
    of Token.noteq: output = output & " != "
    of Token.cnot: output = output & " not "
    of Token.dotdot:
      if lookback(tbl, Token.num, i) and lookahead(tbl, Token.num, i):
        lhs = tbl[i - 1][1]
        rhs = tbl[i + 1][1]
      else:
        error("Line " & $line & ": Expected a number.")
      output = output & "range(" & lhs & ", " & $(parseInt(rhs) + 1) & ")"
    of Token.dot: output = output & "."
    of Token.lbrace:
      output = output & ": "
      indentLevel = indentLevel + 2
    of Token.rbrace:
      output = output
      indentLevel = indentLevel - 2
    of Token.newline:
      inc line
      output = output & "\n" & repeat(' ', indentLevel)
    else: error("'" & tok & "' is not defined or is defined elsewhere")
  return output