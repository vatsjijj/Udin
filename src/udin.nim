#      ___           ___                       ___     
#     /\__\         /\  \          ___        /\__\    
#    /:/  /        /::\  \        /\  \      /::|  |   
#   /:/  /        /:/\:\  \       \:\  \    /:|:|  |   
#  /:/  /  ___   /:/  \:\__\      /::\__\  /:/|:|  |__ 
# /:/__/  /\__\ /:/__/ \:|__|  __/:/\/__/ /:/ |:| /\__\
# \:\  \ /:/  / \:\  \ /:/  / /\/:/  /    \/__|:|/:/  /
#  \:\  /:/  /   \:\  /:/  /  \::/__/         |:/:/  / 
#   \:\/:/  /     \:\/:/  /    \:\__\         |::/  /  
#    \::/  /       \::/__/      \/__/         /:/  /   
#     \/__/         ~~                        \/__/    

import std/[sequtils, os, osproc, strutils, strformat], scan, util

var name: string
var oldLen: int = 0

if paramCount() >= 2:
  name = paramStr(2)
  name.delete((len(name) - 5)..(len(name) - 1))
else:
  info("Usage instructions:")
  echo "  udin [g, r, c] <filename> [o] <output name>"
  echo "  g -> Output generated Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")

var input: seq[char] = (readFile(name & ".udin") & '\0').toSeq

proc check(name: string) =
  if execCmd(fmt"mypy {name}.py") != 0:
    discard execCmd("rm *.py &> /dev/null")
    discard execCmd("rm -rf build/ &> /dev/null")
    quit(1)

scan(input)

if paramCount() >= 2:
  if execCmd("which mypy &> /dev/null") != 0:
    error("Mypy is needed to run Udin code.")
  if paramStr(1) == "g":
    if paramCount() == 4:
      if paramStr(3) == "o":
        writeFile("./" & paramStr(4) & ".py", transpile())
        if len(toTranspile) >= 1:
          while true:
            ip = 0
            var newLen = len(toTranspile)
            if oldLen == newLen:
              break
            else:
              scan((readFile(toTranspile[oldLen] & ".udin") & '\0').toSeq)
              writeFile("./" & toTranspile[oldLen] & "_udin.py", transpile())
            oldLen = newLen
          for i in 0..len(toTranspile) - 1:
            check(toTranspile[i] & "_udin")
        check(name)
    else:
      writeFile(fmt"./{name}.py", transpile())
      if len(toTranspile) >= 1:
        while true:
          ip = 0
          var newLen = len(toTranspile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toTranspile[oldLen] & ".udin") & '\0').toSeq)
            writeFile("./" & toTranspile[oldLen] & "_udin.py", transpile())
          oldLen = newLen
        for i in 0..len(toTranspile) - 1:
          check(toTranspile[i] & "_udin")
      check(name)
  if paramStr(1) == "r":
    writeFile(fmt"./{name}.py", transpile())
    if len(toTranspile) >= 1:
      while true:
        ip = 0
        var newLen = len(toTranspile)
        if oldLen == newLen:
          break
        else:
          scan((readFile(toTranspile[oldLen] & ".udin") & '\0').toSeq)
          writeFile("./" & toTranspile[oldLen] & "_udin.py", transpile())
        oldLen = newLen
      for i in 0..len(toTranspile) - 1:
        check(toTranspile[i] & "_udin")
    check(name)
    discard execCmd(fmt"python3 ./{name}.py")
    discard execCmd("rm *.py &> /dev/null")
  if paramStr(1) == "c":
    if execCmd("which pyinstaller &> /dev/null") != 0:
      error("To compile binaries you need Pyinstaller!")
    else:
      writeFile(fmt"./{name}.py", transpile())
      if len(toTranspile) >= 1:
        while true:
          ip = 0
          var newLen = len(toTranspile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toTranspile[oldLen] & ".udin") & '\0').toSeq)
            writeFile("./" & toTranspile[oldLen] & "_udin.py", transpile())
          oldLen = newLen
        for i in 0..len(toTranspile) - 1:
          check(toTranspile[i] & "_udin")
      check(name)
      if paramCount() == 4:
        if paramStr(3) == "o":
          discard execCmd(fmt"pyinstaller -F {name}.py --clean -n " & paramStr(4))
          discard execCmd("rm *.py &> /dev/null")
          discard execCmd("rm -rf ./build &> /dev/null")
          discard execCmd("mv ./dist/* . &> /dev/null")
          discard execCmd("rm -rf ./dist &> /dev/null")
          discard execCmd("rm *.spec &> /dev/null")
      else:
        discard execCmd(fmt"pyinstaller -F {name}.py --clean -n {name}")
        discard execCmd("rm *.py &> /dev/null")
        discard execCmd("rm -rf ./build &> /dev/null")
        discard execCmd("mv ./dist/* . &> /dev/null")
        discard execCmd("rm -rf ./dist &> /dev/null")
        discard execCmd("rm *.spec &> /dev/null")
else:
  info("Usage instructions:")
  echo "  udin [g, r, c] <filename> [o] <output name>"
  echo "  g -> Output generated Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")