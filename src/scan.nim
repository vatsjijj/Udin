import std/[strutils, os], util

type
  Token* = enum
    # special
    enablememo,
    # misc
    atom,
    num,
    str,
    # one char tokens
    newline,
    colon,
    semicolon,
    comma,
    dot,
    gt, lt,
    plus, minus,
    fslash, star,
    omod,
    pipe,
    underscore,
    equ,
    lparen, rparen,
    lbrace, rbrace,
    lbrack, rbrack,
    decorate,
    # two char tokens
    floordiv,
    dotdot,
    rarrow,
    equequ,
    gteq, lteq,
    dcolon,
    noteq,
    concat,
    cand,
    cor,
    cnot,
    # keywords
    dataclass,
    enm,
    fun,
    put,
    ret,
    cont,
    loop,
    imprt,
    frm,
    brk,
    inmain,
    class,
    init,
    mrepr,
    meq,
    madd,
    nothing,
    isinstance,
    this,
    whle,
    match,
    cof,
    cfor,
    cin,
    btrue,
    bfalse,
    cif,
    celse,
    celif,
    pstring,
    pinteger,
    pfloat,
    pboolean,
    pbyte,
    plist,
    pset,
    pdict,
    ptuple,
    none,
    pany,
    ignoretype,
    ilgl

var
  ip*: int = 0
  rawTok*: seq[char] = @[]
  tok*: string = ""
  tokenTable*: seq[(Token, string)]
  indentLevel: int = 0
  line: int = 1
  lhs, rhs: string
  isEnum: bool = false
  isDClass: bool = false
  isMemo: bool = false
  isList: bool = false
  isParens: bool = false
  toCompile*: seq[string]
  toDel*: seq[string]
  types: seq[Token] = @[
    Token.atom, Token.str,
    Token.num, Token.btrue,
    Token.bfalse, Token.underscore,
    Token.pstring,
    Token.pinteger, Token.pfloat,
    Token.pboolean, Token.pbyte,
    Token.plist, Token.pset,
    Token.pdict, Token.ptuple,
    Token.none, Token.pany,
    Token.put, Token.newline
  ]
  keywords: seq[Token] = @[
    Token.fun, Token.put,
    Token.ret, Token.cont,
    Token.loop, Token.imprt,
    Token.frm, Token.brk,
    Token.inmain, Token.class,
    Token.init, Token.mrepr,
    Token.meq, Token.madd,
    Token.nothing, Token.isinstance,
    Token.this, Token.whle,
    Token.match, Token.cof,
    Token.cfor, Token.cin,
    Token.btrue, Token.bfalse,
    Token.cif, Token.celse,
    Token.celif, Token.pstring,
    Token.pinteger, Token.pfloat,
    Token.pboolean, Token.pbyte,
    Token.plist, Token.pset,
    Token.pdict, Token.ptuple,
    Token.none, Token.pany,
    Token.ignoretype
  ]

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
  of "enum":
    isEnum = true
    return (Token.enm, tok)
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
  of "match": return (Token.match, tok)
  of "of": return (Token.cof, tok)
  of "loop": return (Token.loop, tok)
  of "break": return (Token.brk, tok)
  of "nameMain": return (Token.inmain, tok)
  of "isInstance": return (Token.isinstance, tok)
  of "String": return (Token.pstring, tok)
  of "Int": return (Token.pinteger, tok)
  of "Float": return (Token.pfloat, tok)
  of "Bool": return (Token.pboolean, tok)
  of "Byte": return (Token.pbyte, tok)
  of "List": return (Token.plist, tok)
  of "Set": return (Token.pset, tok)
  of "Dict": return (Token.pdict, tok)
  of "Tuple": return (Token.ptuple, tok)
  of "None": return (Token.none, tok)
  of "Any": return (Token.pany, tok)
  of "ignoreType": return (Token.ignoretype, tok)
  of "memo":
    isMemo = true
    return (Token.enablememo, tok)
  of "dataclass":
    isDClass = true
    return (Token.dataclass, tok)
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
    elif atEnd(src):
      error("Non-terminated string.")
  tok = toString(rawTok)
  return (Token.str, tok)

proc symbol(src: seq[char]): (Token, string) =
  case src[ip]
  of '@': return (Token.decorate, "@")
  of '#':
    while src[ip] != '\n' and not atEnd(src):
      inc ip
    discard
  of '(': return (Token.lparen, "(")
  of ')': return (Token.rparen, ")")
  of '"': return lexStr(src)
  of ':':
    if src[ip + 1] == ':':
      inc ip
      return (Token.dcolon, "::")
    else:
      return (Token.colon, ":")
  of ';': return (Token.semicolon, ";")
  of '{': return (Token.lbrace, "{")
  of '}': return (Token.rbrace, "}")
  of '[': return (Token.lbrack, "[")
  of ']': return (Token.rbrack, "]")
  of ',': return (Token.comma, ",")
  of '_': return (Token.underscore, "_")
  of '+': return (Token.plus, "+")
  of '-':
    if src[ip + 1] == '>':
      inc ip
      return (Token.rarrow, "->")
    else:
      return (Token.minus, "-")
  of '/':
    if src[ip + 1] == '/':
      inc ip
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
    elif src[ip + 1] == '>':
      inc ip
      return (Token.concat, "<>")
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

proc compile*(tbl: seq[(Token, string)] = tokenTable): string =
  var output: string = "# Generated by Udin 0.4.4\n\n"
  if isEnum or isDClass or isMemo:
    output = output & "# Start Udin import #\n"
    if isEnum:
      output = output & "import enum\n"
    if isDClass:
      output = output & "from dataclasses import dataclass\n"
    if isMemo:
      output = output & "from functools import cache\n"
    output = output & "# End Udin import #\n\n"
  isDClass = false
  isEnum = false
  isMemo = false
  for i in 0..len(tbl) - 1:
    case tbl[i][0]
    of Token.dataclass:
      if not lookahead(tbl, Token.atom, i):
        error("Line " & $line & ": Expected a name after 'dataclass'.")
      else:
        rhs = tbl[i + 1][1]
        output = output & "@dataclass\nclass " & rhs
    of Token.enm:
      if not lookahead(tbl, Token.atom, i):
        error("Line " & $line & ": Expected a name after 'enum'.")
      else:
        rhs = tbl[i + 1][1]
        output = output & "class " & rhs & "(enum.Enum)"
    of Token.enablememo:
      if i != 0:
        if not lookback(tbl, Token.decorate, i):
          error("Line " & $line & ": 'memo' is a decorator and expects '@' before it.")
        else:
          output = output & "cache"
      else:
        error("Line " & $line & ": 'memo' is a decorator and expects '@' before it.")
    of Token.decorate: output = output & "@"
    of Token.ignoretype: output = output & " # type: ignore"
    of Token.pany: output = output & "any"
    of Token.plist: output = output & "list"
    of Token.pset: output = output & "set"
    of Token.pdict: output = output & "dict"
    of Token.ptuple: output = output & "tuple"
    of Token.none: output = output & "None"
    of Token.dcolon: output = output & " -> "
    of Token.pbyte: output = output & "bytes"
    of Token.pstring: output = output & "str"
    of Token.pinteger: output = output & "int"
    of Token.pfloat: output = output & "float"
    of Token.pboolean: output = output & "bool"
    of Token.underscore:
      if lookahead(tbl, Token.rarrow, i):
        continue
      else:
        output = output & "_"
    of Token.isinstance: output = output & "isinstance"
    of Token.inmain: output = output & "if __name__ == '__main__'"
    of Token.brk: output = output & "break"
    of Token.match:
      if lookahead(tbl, Token.atom, i):
        output = output & "match "
      else:
        error("Line " & $line & ": Expected an atom after 'match' statement.")
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
        error("Line " & $line & ": Expected an atom after 'for' keyword.")
    of Token.cin: output = output & " in "
    of Token.class: output = output & "class "
    of Token.init:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__init__"
      else:
        error("Line " & $line & ": Expected parenthese after 'init' keyword.")
    of Token.mrepr:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__repr__"
      else:
        error("Line " & $line & ": Expected parenthese after 'repr' keyword.")
    of Token.meq:
      if lookahead(tbl, Token.lparen, i):
        output = output & "__eq__"
      else:
        error("Line " & $line & ": Expected parenthese after 'eq' keyword.")
    of Token.this: output = output & "self"
    of Token.loop: output = output & "while True"
    of Token.imprt:
      if i != 0:
        if lookback(tbl, Token.atom, i):
          output = output & " import "
      else:
        if lookahead(tbl, Token.atom, i):
          output = output & "import "
          if not fileExists(tbl[i + 1][1] & ".udin") and not lookahead(tbl, Token.star, i):
            info("No Udin module named '" & tbl[i + 1][1] & "' found, using Python instead.")
          else:
            if toCompile.contains(tbl[i + 1][1] & "_udin"):
              output = output & tbl[i + 1][1] & "_udin"
              continue
            else:
              toCompile.add(tbl[i + 1][1])
              toDel.add(tbl[i + 1][1])
              output = output & tbl[i + 1][1] & "_udin"
        else:
          error("Line " & $line & ": Expected a module name after 'import' statement.")
    of Token.frm:
      if lookahead(tbl, Token.atom, i):
        output = output & "from "
        if not fileExists(tbl[i + 1][1] & ".udin"):
            info("No Udin module named '" & tbl[i + 1][1] & "' found, using Python instead.")
        else:
          if toCompile.contains(tbl[i + 1][1] & "_udin"):
            output = output & tbl[i + 1][1] & "_udin"
            continue
          else:
            toCompile.add(tbl[i + 1][1])
            toDel.add(tbl[i + 1][1])
            output = output & tbl[i + 1][1] & "_udin"
      else:
        error("Line " & $line & ": Expected an atom after 'from' statement.")
    of Token.btrue: output = output & "True"
    of Token.bfalse: output = output & "False"
    of Token.nothing: output = output & "pass"
    of Token.madd: output = output & "__add__"
    of Token.cif: output = output & "if "
    of Token.celse: output = output & "else"
    of Token.celif: output = output & "elif "
    of Token.cand: output = output & " and "
    of Token.cor: output = output & " or "
    of Token.lparen:
      isParens = true
      output = output & "("
    of Token.rparen:
      isParens = false
      output = output & ")"
    of Token.lbrack:
      isList = true
      output = output & "["
    of Token.rbrack:
      isList = false
      output = output & "]"
    of Token.pipe: output = output & " | "
    of Token.atom:
      if i != 0:
        if lookback(tbl, Token.imprt, i) or lookback(tbl, Token.frm, i):
          if fileExists(tbl[i][1] & ".udin"):
            continue
          else:
            output = output & tbl[i][1]
        elif lookahead(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.enm, i):
          continue
        elif lookback(tbl, Token.dataclass, i):
          continue
        else:
          output = output & tbl[i][1]
      else:
        output = output & tbl[i][1]
    of Token.num:
      if i != 0:
        if lookahead(tbl, Token.dotdot, i):
          continue
        elif lookback(tbl, Token.dotdot, i):
          continue
        elif lookahead(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.rarrow, i):
          continue
        else:
          output = output & tbl[i][1]
      else:
        output = output & tbl[i][1]
    of Token.str:
      if i != 0:
        if lookahead(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.rarrow, i):
          continue
        else:
          output = output & "\"" & tbl[i][1] & "\""
      else:
        output = output & "\"" & tbl[i][1] & "\""
    of Token.colon: output = output & ": "
    of Token.semicolon: output = output & "; "
    of Token.comma: output = output & ", "
    of Token.plus:
      if i != 0:
        if not (lookahead(tbl, Token.num, i) or lookahead(tbl, Token.atom, i)) and not (lookback(tbl, Token.num, i) or lookback(tbl, Token.atom, i)):
          error("Line " & $line & ": Unsupported types for addition operator.")
        else:
          output = output & " + "
    of Token.concat:
      if i != 0:
        if not (lookahead(tbl, Token.str, i) or lookahead(tbl, Token.atom, i)) and not (lookback(tbl, Token.str, i) or lookback(tbl, Token.atom, i)):
          error("Line " & $line & ": Unsupported types for concatenation operator.")
        else:
          output = output & " + "
    of Token.minus: output = output & " - "
    of Token.fslash: output = output & " / "
    of Token.star:
      if lookback(tbl, Token.imprt, i):
        output = output & "*"
      else:
        output = output & " * "
    of Token.omod: output = output & " % "
    of Token.floordiv: output = output & " // "
    of Token.rarrow:
      if types.contains(tbl[i - 1][0]):
        if lookback(tbl, Token.str, i):
          lhs = "\"" & tbl[i - 1][1] & "\""
        else:
          lhs = tbl[i - 1][1]
        if types.contains(tbl[i + 1][0]) or tbl[i + 1][0] == Token.lbrace or tbl[i + 1][0] == Token.ret:
          if lookahead(tbl, Token.str, i):
            rhs = " \"" & tbl[i + 1][1] & "\""
          else:
            if tbl[i + 1][1] != "put" and tbl[i + 1][1] != "ret" and tbl[i + 1][1] != "nl" and tbl[i + 1][1] != "{":
              rhs = tbl[i + 1][1]
          if lookahead(tbl, Token.lbrace, i):
            output = output & "case " & lhs
          else:
            output = output & "case " & lhs & ": " & rhs
        else:
          error("Line " & $line & ": Invalid match parameter on right hand side.")
      else:
        error("Line " & $line & ": Invalid match parameter on left hand side.")
    of Token.equ:
      if keywords.contains(tbl[i - 1][0]):
        if types.contains(tbl[i - 1][0]):
          output = output & " = "
          continue
        else:
          error("Line " & $line & ": '" & tbl[i - 1][1] & "' is a reserved keyword and cannot be assigned to.")
      elif not lookback(tbl, Token.atom, i):
        if types.contains(tbl[i - 1][0]):
          output = output & " = "
          continue
        else:
          warn("Line " & $line & ": Cannot assign a value to an object of type '" & $tbl[i - 1][0] & "'. Did you mean '=='?")
          error("Line " & $line & ": '" & tbl[i - 1][1] & "' is of type '" & $tbl[i - 1][0] & "' and cannot be assigned to.")
      else:
        output = output & " = "
    of Token.equequ: output = output & " == "
    of Token.lt: output = output & " < "
    of Token.gt: output = output & " > "
    of Token.lteq: output = output & " <= "
    of Token.gteq: output = output & " >= "
    of Token.noteq: output = output & " != "
    of Token.cnot: output = output & "not "
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
      if isList or isParens:
        continue
      else:
        output = output & "\n" & repeat(' ', indentLevel)
    else: error("'" & tok & "' is not defined or is defined elsewhere")
  tokenTable = @[]
  return output