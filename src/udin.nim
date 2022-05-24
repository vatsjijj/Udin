#       ___           ___           ___           ___                       ___     
#      /\__\         /\__\         /\__\         /\  \          ___        /\__\    
#     /:/  /        /:/ _/_       /:/  /        /::\  \        /\  \      /::|  |   
#    /:/  /        /:/ /\__\     /:/  /        /:/\:\  \       \:\  \    /:|:|  |   
#   /:/  /  ___   /:/ /:/ _/_   /:/  /  ___   /:/  \:\__\      /::\__\  /:/|:|  |__ 
#  /:/__/  /\__\ /:/_/:/ /\__\ /:/__/  /\__\ /:/__/ \:|__|  __/:/\/__/ /:/ |:| /\__\
#  \:\  \ /:/  / \:\/:/ /:/  / \:\  \ /:/  / \:\  \ /:/  / /\/:/  /    \/__|:|/:/  /
#   \:\  /:/  /   \::/_/:/  /   \:\  /:/  /   \:\  /:/  /  \::/__/         |:/:/  / 
#    \:\/:/  /     \:\/:/  /     \:\/:/  /     \:\/:/  /    \:\__\         |::/  /  
#     \::/  /       \::/  /       \::/  /       \::/__/      \/__/         /:/  /   
#      \/__/         \/__/         \/__/         ~~                        \/__/    
# That's right, UwUdin, you filthy animal.

import std/[sequtils, os, osproc, strutils, strformat], scan, util

var name: string
var oldLen: int = 0

if paramCount() >= 2:
  name = paramStr(2)
  name.delete((len(name) - 5)..(len(name) - 1))
else:
  info("Usage instructions:")
  echo "  udin [t, r, c] <filename> [o] <output name>"
  echo "  t -> Transpile Udin source to Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")

var input: seq[char] = (readFile(name & ".udin") & '\0').toSeq

scan(input)

if paramCount() >= 2:
  if paramStr(1) == "t":
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
    discard execCmd(fmt"python3 ./{name}.py")
    discard execCmd("rm *.py")
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
      if paramCount() == 4:
        if paramStr(3) == "o":
          discard execCmd(fmt"pyinstaller -F {name}.py --clean -n " & paramStr(4))
          discard execCmd("rm *.py")
          discard execCmd("rm -rf ./build")
          discard execCmd("mv ./dist/* .")
          discard execCmd("rm -rf ./dist")
          discard execCmd("rm *.spec")
      else:
        discard execCmd(fmt"pyinstaller -F {name}.py --clean -n {name}")
        discard execCmd("rm *.py")
        discard execCmd("rm -rf ./build")
        discard execCmd("mv ./dist/* .")
        discard execCmd("rm -rf ./dist")
        discard execCmd("rm *.spec")
else:
  info("Usage instructions:")
  echo "  udin [t, r, c] <filename> [o] <output name>"
  echo "  t -> Transpile Udin source to Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")