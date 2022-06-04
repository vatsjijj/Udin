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

import std/[sequtils, os, osproc, strutils, strformat, distros], scan, util

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
    if detectOs(Linux):
      discard execCmd("rm *.py &> /dev/null")
      discard execCmd("rm -rf build/ &> /dev/null")
    elif detectOs(Windows):
      removeFile(name & ".py")
      for i in 0..len(toDel) - 1:
        removeFile(toDel[i] & "_udin.py")
      removeDir("build")
    quit(1)

scan(input)

if paramCount() >= 2:
  if detectOs(Linux) and execCmd("which mypy &> /dev/null") != 0:
    error("Mypy is needed to run Udin code.")
  elif detectOs(Windows) and execCmd("where /Q mypy") != 0:
    error("Mypy is needed to run Udin code.")
  if paramStr(1) == "g":
    if paramCount() == 4:
      if paramStr(3) == "o":
        writeFile(paramStr(4) & ".py", compile())
        if len(toCompile) >= 1:
          while true:
            ip = 0
            var newLen = len(toCompile)
            if oldLen == newLen:
              break
            else:
              scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
              writeFile(toCompile[oldLen] & "_udin.py", compile())
            oldLen = newLen
          for i in 0..len(toCompile) - 1:
            check(toCompile[i] & "_udin")
        check(name)
    else:
      writeFile(fmt"{name}.py", compile())
      if len(toCompile) >= 1:
        while true:
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile(toCompile[oldLen] & "_udin.py", compile())
          oldLen = newLen
        for i in 0..len(toCompile) - 1:
          check(toCompile[i] & "_udin")
      check(name)
  if paramStr(1) == "r":
    writeFile(fmt"{name}.py", compile())
    if len(toCompile) >= 1:
      while true:
        ip = 0
        var newLen = len(toCompile)
        if oldLen == newLen:
          break
        else:
          scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
          writeFile(toCompile[oldLen] & "_udin.py", compile())
        oldLen = newLen
      for i in 0..len(toCompile) - 1:
        check(toCompile[i] & "_udin")
    check(name)
    if detectOs(Linux):
      discard execCmd(fmt"python3 {name}.py")
    elif detectOs(Windows):
      discard execCmd(fmt"{name}.py")
    if detectOs(Linux):
      discard execCmd("rm *.py &> /dev/null")
    elif detectOs(Windows):
      removeFile(name & ".py")
      for i in 0..len(toDel) - 1:
        removeFile(toDel[i] & "_udin.py")
  if paramStr(1) == "c":
    if detectOs(Linux) and execCmd("which pyinstaller &> /dev/null") != 0:
      error("To compile binaries you need Pyinstaller!")
    elif detectOs(Windows) and execCmd("where /Q pyinstaller") != 0:
      error("To compile binaries you need Pyinstaller!")
    else:
      writeFile(fmt"{name}.py", compile())
      if len(toCompile) >= 1:
        while true:
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile(toCompile[oldLen] & "_udin.py", compile())
          oldLen = newLen
        for i in 0..len(toCompile) - 1:
          check(toCompile[i] & "_udin")
      check(name)
      if paramCount() == 4:
        if paramStr(3) == "o":
          discard execCmd(fmt"pyinstaller -F {name}.py --clean -n " & paramStr(4))
          if detectOs(Linux):
            discard execCmd("rm *.py &> /dev/null")
            discard execCmd("rm -rf ./build &> /dev/null")
            discard execCmd("mv ./dist/* . &> /dev/null")
            discard execCmd("rm -rf ./dist &> /dev/null")
            discard execCmd("rm *.spec &> /dev/null")
          elif detectOs(Windows):
            removeFile(name & ".py")
            for i in 0..len(toDel) - 1:
              removeFile(toDel[i] & "_udin.py")
            removeDir("build")
            moveFile("dist\\" & name, ".")
            removeDir("dist")
            removeFile(name & ".spec")
      else:
        discard execCmd(fmt"pyinstaller -F {name}.py --clean -n {name}")
        if detectOs(Linux):
          discard execCmd("rm *.py &> /dev/null")
          discard execCmd("rm -rf ./build &> /dev/null")
          discard execCmd("mv ./dist/* . &> /dev/null")
          discard execCmd("rm -rf ./dist &> /dev/null")
          discard execCmd("rm *.spec &> /dev/null")
        elif detectOs(Windows):
          removeFile(name & ".py")
          for i in 0..len(toDel) - 1:
            removeFile(toDel[i] & "_udin.py")
          removeDir("build")
          moveFile("dist\\" & name, ".")
          removeDir("dist")
          removeFile(name & ".spec")
else:
  info("Usage instructions:")
  echo "  udin [g, r, c] <filename> [o] <output name>"
  echo "  g -> Output generated Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")