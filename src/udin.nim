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
var fullLst: string

if not detectOs(Linux) and not detectOs(Windows):
  error("Your operating system is unsupported.")

if paramCount() >= 2:
  if detectOs(Linux):
    name = paramStr(2)
  elif detectOs(Windows):
    name = commandLineParams()[1]
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

scan(input)

if paramCount() >= 2:
  if paramStr(1) == "g" or commandLineParams()[0] == "g":
    if paramCount() == 4:
      if paramStr(3) == "o" or commandLineParams()[2] == "o":
        writeFile(paramStr(4) & ".py", compile())
        if len(toCompile) >= 1:
          while true:
            line = 2
            ip = 0
            var newLen = len(toCompile)
            if oldLen == newLen:
              break
            else:
              scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
              writeFile(toCompile[oldLen] & "_udin.py", compile())
            inc oldLen
        for i in 0..len(toCompile) - 1:
          fullLst = fullLst & toCompile[i] & "_udin.py "
        fullLst = fullLst & name & ".py"
    else:
      writeFile(fmt"{name}.py", compile())
      if len(toCompile) >= 1:
        while true:
          line = 2
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile(toCompile[oldLen] & "_udin.py", compile())
          inc oldLen
      for i in 0..len(toCompile) - 1:
        fullLst = fullLst & toCompile[i] & "_udin.py "
      fullLst = fullLst & name & ".py"
  if paramStr(1) == "r" or commandLineParams()[0] == "r":
    writeFile(fmt"{name}.py", compile())
    if len(toCompile) >= 1:
      while true:
        line = 2
        ip = 0
        var newLen = len(toCompile)
        if oldLen == newLen:
          break
        else:
          scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
          writeFile(toCompile[oldLen] & "_udin.py", compile())
        inc oldLen
    for i in 0..len(toCompile) - 1:
      if not fullLst.contains(toCompile[i]):
        fullLst = fullLst & toCompile[i] & "_udin.py "
    fullLst = fullLst & name & ".py"
    if detectOs(Linux):
      discard execCmd(fmt"python3 {name}.py")
    elif detectOs(Windows):
      discard execCmd(fmt"py {name}.py")
    if detectOs(Linux):
      discard execCmd("rm *.py &> /dev/null")
    elif detectOs(Windows):
      removeFile(name & ".py")
      for i in 0..len(toDel) - 1:
        removeFile(toDel[i] & "_udin.py")
  if paramStr(1) == "c" or commandLineParams()[0] == "c":
    if detectOs(Linux) and execCmd("which pyinstaller &> /dev/null") != 0:
      error("To compile binaries you need Pyinstaller!")
    elif detectOs(Windows) and execCmd("where /Q pyinstaller") != 0:
      error("To compile binaries you need Pyinstaller!")
    else:
      writeFile(fmt"{name}.py", compile())
      if len(toCompile) >= 1:
        while true:
          line = 2
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile(toCompile[oldLen] & "_udin.py", compile())
          inc oldLen
      if len(toCompile) == 1:
        fullLst = toCompile[0] & "_udin.py"
      else:
        fullLst = toCompile.join("_udin.py ")
      fullLst = [fullLst, name & ".py"].join(" ")
      if paramCount() == 4:
        if paramStr(3) == "o" or commandLineParams()[2] == "o":
          if detectOs(Linux):
            discard execCmd(fmt"pyinstaller -F {name}.py --clean -n " & paramStr(4))
            discard execCmd("rm *.py &> /dev/null")
            discard execCmd("rm -rf ./build &> /dev/null")
            discard execCmd("mv ./dist/* . &> /dev/null")
            discard execCmd("rm -rf ./dist &> /dev/null")
            discard execCmd("rm *.spec &> /dev/null")
          elif detectOs(Windows):
            discard execCmd(fmt"pyinstaller -F {name}.py --clean -n " & commandLineParams()[3])
            removeFile(name & ".py")
            for i in 0..len(toDel) - 1:
              removeFile(toDel[i] & "_udin.py")
            removeDir("build")
            moveFile("dist\\" & commandLineParams()[3] & ".exe", ".")
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
          removeFile(name & ".spec")
else:
  info("Usage instructions:")
  echo "  udin [g, r, c] <filename> [o] <output name>"
  echo "  g -> Output generated Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")