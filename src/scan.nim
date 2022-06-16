import std/[strutils, os, distros], util

var name: string
var fname: string
var nname: seq[string]
var wdir: string

if paramCount() >= 2:
  if detectOs(Linux):
    name = paramStr(2)
  elif detectOs(Windows):
    name = commandLineParams()[1]
  name.delete((len(name) - 5)..(len(name) - 1))
  if detectOs(Linux):
    nname = name.split("/")
  elif detectOs(Windows):
    nname = name.split("\\")
  if len(nname) == 2:
    wdir = nname[0]
    fname = nname[1]
  elif len(nname) == 1:
    wdir = ""
    fname = nname[0]

type
  Token* = enum
    # misc
    atom,
    num,
    str,
    indt,
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
    incr,
    decr,
    dictb,
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
    global,
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
  line*: int = 1
  lhs, rhs: string
  isEnum: bool = false
  isDClass: bool = false
  isList: bool = false
  isParens: bool = false
  isIf: bool = false
  isWhile: bool = false
  isFun: bool = false # Udin is fun, but this variable clearly isn't.
  isBrace: bool = false
  isMatch: bool = false
  isFor: bool = false
  isLoop: bool = false
  toCompile*: seq[string]
  toDel*: seq[string]
  globalTable: seq[string]
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
    Token.put, Token.newline,
    Token.rbrack
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
  if index != len(tbl) - 1:
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
  of "madd": return (Token.madd, tok)
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
  of "dataclass":
    isDClass = true
    return (Token.dataclass, tok)
  of "global": return (Token.global, tok)
  of "def":
    warn("'def' was used instead of 'fun'.")
    error("Line " & $line & ": Invalid function keyword was used.")
  of "and":
    warn("'and' was used instead of '&&'.")
    error("Line " & $line & ": Invalid keyword was used.")
  of "or":
    warn("'or' was used instead of '||'.")
    error("Line " & $line & ": Invalid keyword was used.")
  else: return (Token.atom, tok)

proc alpha(src: seq[char]): (Token, string) =
  while isAlphaAscii(src[ip]):
    rawTok.add(src[ip])
    if src[ip + 1] == '_':
      inc ip
      rawTok.add(src[ip])
    elif isDigit(src[ip + 1]):
      inc ip
      rawTok.add(src[ip])
    elif src[ip + 1] == '/' or src[ip + 1] == '\\':
      inc ip
      if detectOs(Linux):
        rawTok.add('/')
      elif detectOs(Windows):
        rawTok.add('\\')
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
      error("Line " & $line & ": Non-terminated string.")
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
  of '+':
    if src[ip + 1] == '+':
      inc ip
      return (Token.incr, "++")
    else:
      return (Token.plus, "+")
  of '-':
    if src[ip + 1] == '>':
      inc ip
      return (Token.rarrow, "->")
    elif src[ip + 1] == '-':
      inc ip
      return (Token.decr, "--")
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
  else: discard

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
        inc line
        inc ip
        tokenTable.add((newline, "nl"))
        while src[ip] == ' ':
          inc ip
          tokenTable.add((indt, "indent"))
      else:
        inc ip
    else:
      rawTok = @[]
      tokenTable.add(symbol(src))
      inc ip

proc compile*(tbl: seq[(Token, string)] = tokenTable): string =
  var output: string = "# Generated by Udin 0.7.0\n\n"
  if isEnum or isDClass:
    output = output & "# Start Udin import #\n"
    if isEnum:
      output = output & "from enum import Enum, auto\n"
    if isDClass:
      output = output & "from dataclasses import dataclass\n"
    output = output & "# End Udin import #\n\n"
  isDClass = false
  isEnum = false
  for i in 0..len(tbl) - 1:
    case tbl[i][0]
    of Token.incr:
      if lookback(tbl, Token.atom, i):
        lhs = tbl[i - 1][1]
        output = output & lhs & " += 1"
      elif lookahead(tbl, Token.atom, i):
        rhs = tbl[i + 1][1]
        output = output & rhs & " += 1"
      else:
        error("Line " & $line & ": Invalid type for increment operator.")
    of Token.decr:
      if lookback(tbl, Token.atom, i):
        lhs = tbl[i - 1][1]
        output = output & lhs & " -= 1"
      elif lookahead(tbl, Token.atom, i):
        rhs = tbl[i + 1][1]
        output = output & rhs & " -= 1"
      else:
        error("Line " & $line & ": Invalid type for decrement operator.")
    of Token.global:
      if lookahead(tbl, Token.atom, i):
        globalTable.add(tbl[i + 1][1])
      else:
        error("Line " & $line & ": Improper use of the 'global' keyword.")
    of Token.dataclass:
      if not lookahead(tbl, Token.atom, i):
        error("Line " & $line & ": Expected a name after 'dataclass'.")
      else:
        isDClass = true
        if indentLevel > 0:
          warn("Line " & $line & ": Dataclasses should only be declared in toplevel.")
        rhs = tbl[i + 1][1]
        output = output & "@dataclass\n" & repeat(' ', indentLevel) & "class " & rhs
    of Token.enm:
      if not lookahead(tbl, Token.atom, i):
        error("Line " & $line & ": Expected a name after 'enum'.")
      else:
        isEnum = true
        if indentLevel > 0:
          warn("Line " & $line & ": Enums should only be declared in toplevel.")
        rhs = tbl[i + 1][1]
        output = output & "class " & rhs & "(Enum)"
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
        isMatch = true
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
        isFun = true # It's fun now.
        output = output & "def "
      else:
        error("Line " & $line & ": Expected an atom after function definition.")
    of Token.ret: output = output & "return "
    of Token.cont: output = output & "continue"
    of Token.whle:
      isWhile = true
      output = output & "while "
    of Token.cfor:
      if lookahead(tbl, Token.atom, i):
        isFor = true
        output = output & "for "
      else:
        error("Line " & $line & ": Expected an atom after 'for' keyword.")
    of Token.cin: output = output & " in "
    of Token.class:
      if indentLevel > 0:
        warn("Line " & $line & ": Classes should only be declared in toplevel.")
      output = output & "class "
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
    of Token.loop:
      isLoop = true
      output = output & "while True"
    of Token.imprt:
      if i != 0:
        if tbl[i - 1][1] == fname:
          error("Cannot import a module with the same name as the source file.")
        elif lookback(tbl, Token.atom, i):
          continue
      else:
        if tbl[i + 1][1] == fname:
          error("Cannot import a module with the same name as the source file.")
        if lookahead(tbl, Token.atom, i):
          if not fileExists(wdir & "/" & tbl[i + 1][1] & ".udin") and not lookahead(tbl, Token.star, i) and detectOs(Linux):
            continue
          elif not fileExists(wdir & "\\" & tbl[i + 1][1] & ".udin") and not lookahead(tbl, Token.star, i) and detectOs(Windows):
            continue
          else:
            if detectOs(Linux) and toCompile.contains(wdir & "/" & tbl[i + 1][1] & "_udin"):
              output = output & tbl[i + 1][1] & "_udin"
              continue
            elif detectOs(Windows) and toCompile.contains(wdir & "\\" & tbl[i + 1][1] & "_udin"):
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
        rhs = tbl[i + 1][1]
        if not fileExists(wdir & "/" & tbl[i + 1][1] & ".udin") and detectOs(Linux):
          output = output & "from " & rhs & " "
        elif not fileExists(wdir & "\\" & tbl[i + 1][1] & ".udin") and detectOs(Windows):
          output = output & "from " & rhs & " "
        else:
          if detectOs(Linux) and toCompile.contains(wdir & "/" & tbl[i + 1][1] & "_udin"):
            output = output & "from " & rhs & "_udin "
            continue
          elif detectOs(Windows) and toCompile.contains(wdir & "\\" & tbl[i + 1][1] & "_udin"):
            output = output & "from " & rhs & "_udin "
            continue
          else:
            toCompile.add(tbl[i + 1][1])
            toDel.add(tbl[i + 1][1])
            output = output & "from " & rhs & "_udin "
      else:
        error("Line " & $line & ": Expected an atom after 'from' statement.")
    of Token.btrue: output = output & "True"
    of Token.bfalse: output = output & "False"
    of Token.nothing: output = output & "pass"
    of Token.madd: output = output & "__add__"
    of Token.cif:
      isIf = true
      output = output & "if "
    of Token.celse:
      isIf = true
      output = output & "else"
    of Token.celif:
      isIf = true
      output = output & "elif "
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
        if lookback(tbl, Token.imprt, i):
          if detectOs(Linux) and fileExists(wdir & "/" & tbl[i][1] & ".udin"):
            continue
          elif detectOs(Windows) and fileExists(wdir & "\\" & tbl[i][1] & ".udin"):
            continue
          else:
            output = output & "import " & tbl[i][1]
        elif lookback(tbl, Token.frm, i):
          if detectOs(Linux) and fileExists(wdir & "/" & tbl[i][1] & ".udin"):
            continue
          elif detectOs(Windows) and fileExists(wdir & "\\" & tbl[i][1] & ".udin"):
            continue
          else:
            continue
        elif lookahead(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.rarrow, i):
          continue
        elif lookback(tbl, Token.enm, i):
          continue
        elif lookback(tbl, Token.dataclass, i):
          continue
        elif lookback(tbl, Token.global, i):
          output = output & tbl[i][1]
        elif lookahead(tbl, Token.incr, i) or lookahead(tbl, Token.decr, i):
          continue
        elif lookback(tbl, Token.incr, i) or lookback(tbl, Token.decr, i):
          continue
        else:
          if globalTable.contains(tbl[i][1]) and not (isParens or isEnum or isList or isIf or isWhile or isFun):
            output = output & "global " & tbl[i][1] & "\n" & repeat(' ', indentLevel) & tbl[i][1]
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
    of Token.colon:
      isIf = false
      isWhile = false
      isMatch = false
      isFor = false
      isLoop = false
      output = output & ": "
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
        output = output & "import *"
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
      if isFun or isWhile or isIf or isEnum or isDClass or isMatch or isFor or isLoop:
        if isWhile or isIf or isMatch or isFor or isLoop:
          warn("Line " & $line & ": You should use ':' for while, if, else, elif, for, loop, and match blocks.")
        output = output & ": "
        isFun = false # Aww man.
        isIf = false
        isWhile = false
        isEnum = false
        isDClass = false
        isMatch = false
        isFor = false
        isLoop = false
      elif keywords.contains(tbl[i - 1][0]):
        if types.contains(tbl[i - 1][0]):
          output = output & " = "
        else:
          error("Line " & $line & ": '" & tbl[i - 1][1] & "' is a reserved keyword and cannot be assigned to.")
      elif not lookback(tbl, Token.atom, i):
        if types.contains(tbl[i - 1][0]):
          output = output & " = "
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
        if isList:
          var tmp: string = ""
          for j in parseInt(lhs)..parseInt(rhs):
            if j != parseInt(rhs):
              tmp = tmp & $j & ", "
            else:
              tmp = tmp & $j
          output = output & tmp
        else:
          output = output & "range(" & lhs & ", " & $(parseInt(rhs) + 1) & ")"
      else:
        error("Line " & $line & ": Expected a number.")
    of Token.dot: output = output & "."
    of Token.lbrace:
      isBrace = true
      output = output & "{"
    of Token.rbrace:
      isBrace = false
      output = output & "}"
    of Token.indt:
      if isList or isParens:
        continue
      else:
        output = output & " "
        inc indentLevel
    of Token.newline:
      indentLevel = 0
      if isList or isParens:
        continue
      else:
        output = output & "\n"
    else: error("Line " & $line & ": '" & $tbl[i] & "' is not defined or is defined elsewhere")
  tokenTable = @[]
  return output