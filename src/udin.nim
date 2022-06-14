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
var specdir: string
var distdir: string
var builddir: string
var nname: seq[string]
var fname: string
var wdir: string

if not detectOs(Linux) and not detectOs(Windows):
  error("Your operating system is unsupported.")

if detectOs(Linux):
  createDir("/tmp/udincache")
elif detectOs(Windows):
  createDir("C:\\.udincache")

if paramCount() == 1 and (paramStr(1) == "ver" or commandLineParams()[0] == "ver"):
  info("Udin 0.6.4")
  quit(0)
elif paramCount() >= 2:
  if detectOs(Linux):
    name = paramStr(2)
    specdir = getCurrentDir() & "/spec"
    distdir = getCurrentDir() & "/dist"
    builddir = getCurrentDir() & "/build"
  elif detectOs(Windows):
    name = commandLineParams()[1]
    specdir = getCurrentDir() & "\\spec"
    distdir = getCurrentDir() & "\\dist"
    builddir = getCurrentDir() & "\\build"
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
            line = 1
            ip = 0
            var newLen = len(toCompile)
            if oldLen == newLen:
              break
            else:
              scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
              writeFile(toCompile[oldLen] & "_udin.py", compile())
            inc oldLen
    else:
      writeFile(fmt"{name}.py", compile())
      if len(toCompile) >= 1:
        while true:
          line = 1
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            scan((readFile(toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile(toCompile[oldLen] & "_udin.py", compile())
          inc oldLen
  if paramStr(1) == "r" or commandLineParams()[0] == "r":
    if detectOs(Linux):
      writeFile(fmt"/tmp/udincache/{fname}.py", compile())
    elif detectOs(Windows):
      writeFile(fmt"C:\.udincache\{fname}.py", compile())
    if len(toCompile) >= 1:
      while true:
        line = 1
        ip = 0
        var newLen = len(toCompile)
        if oldLen == newLen:
          break
        else:
          if detectOs(Linux):
            scan((readFile(wdir & "/" & toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile("/tmp/udincache/" & toCompile[oldLen] & "_udin.py", compile())
          elif detectOs(Windows):
            scan((readFile(wdir & "\\" & toCompile[oldLen] & ".udin") & '\0').toSeq)
            writeFile("C:\\.udincache\\" & toCompile[oldLen] & "_udin.py", compile())
        inc oldLen
    if detectOs(Linux):
      discard execCmd(fmt"python3 /tmp/udincache/{fname}.py")
    elif detectOs(Windows):
      discard execCmd(fmt"py C:\.udincache\{fname}.py")
    if detectOs(Linux):
      discard execCmd("rm /tmp/udincache/*.py &> /dev/null")
    elif detectOs(Windows):
      removeFile("C:\\.udincache\\" & name & ".py")
      for i in 0..len(toDel) - 1:
        removeFile("C:\\.udincache\\" & toDel[i] & "_udin.py")
  if paramStr(1) == "c" or commandLineParams()[0] == "c":
    if detectOs(Linux) and execCmd("which pyinstaller &> /dev/null") != 0:
      error("To compile binaries you need Pyinstaller!")
    elif detectOs(Windows) and execCmd("where /Q pyinstaller") != 0:
      error("To compile binaries you need Pyinstaller!")
    else:
      if detectOs(Linux):
        writeFile(fmt"/tmp/udincache/{fname}.py", compile())
      elif detectOs(Windows):
        writeFile(fmt"C:\.udincache\{fname}.py", compile())
      if len(toCompile) >= 1:
        while true:
          line = 1
          ip = 0
          var newLen = len(toCompile)
          if oldLen == newLen:
            break
          else:
            if detectOs(Linux):
              scan((readFile(wdir & "/" & toCompile[oldLen] & ".udin") & '\0').toSeq)
              writeFile("/tmp/udincache/" & toCompile[oldLen] & "_udin.py", compile())
            elif detectOs(Windows):
              scan((readFile(wdir & "\\" & toCompile[oldLen] & ".udin") & '\0').toSeq)
              writeFile("C:\\.udincache\\" & toCompile[oldLen] & "_udin.py", compile())
          inc oldLen
      if paramCount() == 4:
        if paramStr(3) == "o" or commandLineParams()[2] == "o":
          createDir("spec")
          createDir("dist")
          createDir("build")
          if detectOs(Linux):
            discard execCmd(fmt"pyinstaller --specpath {specdir} --distpath {distdir} --workpath {builddir} -F /tmp/udincache/{fname}.py --clean -n " & paramStr(4))
            discard execCmd("rm /tmp/udincache/*.py &> /dev/null")
            discard execCmd("rm -rf ./build &> /dev/null")
            discard execCmd("mv ./dist/* . &> /dev/null")
            discard execCmd("rm -rf ./dist &> /dev/null")
            discard execCmd("rm -rf ./spec/ &> /dev/null")
          elif detectOs(Windows):
            discard execCmd(fmt"pyinstaller --specpath {specdir} --distpath {distdir} --workpath {builddir} -F C:\.udincache\{fname}.py --clean -n " & commandLineParams()[3])
            removeFile("C:\\.udincache\\" & name & ".py")
            for i in 0..len(toDel) - 1:
              removeFile("C:\\.udincache\\" & toDel[i] & "_udin.py")
            removeDir("build")
            moveFile("dist\\" & commandLineParams()[3] & ".exe", ".")
            removeDir("dist")
            removeDir("spec")
      else:
        createDir("spec")
        createDir("dist")
        createDir("build")
        if detectOs(Linux):
          discard execCmd(fmt"pyinstaller --specpath {specdir} --distpath {distdir} --workpath {builddir} -F /tmp/udincache/{fname}.py --clean -n {fname}")
          discard execCmd("rm /tmp/udincache/*.py &> /dev/null")
          discard execCmd("rm -rf ./build &> /dev/null")
          discard execCmd("mv ./dist/* . &> /dev/null")
          discard execCmd("rm -rf ./dist &> /dev/null")
          discard execCmd("rm -rf ./spec/ &> /dev/null")
        elif detectOs(Windows):
          discard execCmd(fmt"pyinstaller --specpath {specdir} --distpath {distdir} --workpath {builddir} -F C:\.udincache\{fname}.py --clean -n {fname}")
          removeFile("C:\\.udincache\\" & name & ".py")
          for i in 0..len(toDel) - 1:
            removeFile("C:\\.udincache\\" & toDel[i] & "_udin.py")
          removeDir("build")
          removeDir("spec")
else:
  info("Usage instructions:")
  echo "  udin [g, r, c] <filename> [o] <output name>"
  echo "  g -> Output generated Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")