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

import std/[sequtils, os, osproc], scan, util

var name: string

if paramCount() >= 2:
  name = paramStr(2)
else:
  info("Usage instructions:")
  echo "  udin [t, r, c] <filename> [o] <output name>"
  echo "  t -> Transpile Udin source to Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")

var input: seq[char] = (readFile(name) & '\0').toSeq

scan(input)

if paramCount() >= 2:
  if paramStr(1) == "t":
    if paramCount() == 4:
      if paramStr(3) == "o":
        writeFile("./" & paramStr(4) & ".py", transpile())
    else:
      writeFile("./generated_code.py", transpile())
  if paramStr(1) == "r":
    writeFile("./tmp.py", transpile())
    discard execCmd("python3 ./tmp.py")
    discard execCmd("rm ./tmp.py")
  if paramStr(1) == "c":
    if execCmd("which patchelf") != 0:
      error("To compile binaries you need patchelf!")
    if execCmd("which nuitka3") != 0:
      error("To compile binaries you need Nuitka!")
    else:
      writeFile("./tmp.py", transpile())
      if paramCount() == 4:
        if paramStr(3) == "o":
          discard execCmd("nuitka3 --follow-imports ./tmp.py -o " & paramStr(4))
          discard execCmd("rm ./tmp.py")
          discard execCmd("rm -rf ./tmp.build")
      else:
        discard execCmd("nuitka3 --follow-imports ./tmp.py -o app")
        discard execCmd("rm ./tmp.py")
        discard execCmd("rm -rf ./tmp.build")
else:
  info("Usage instructions:")
  echo "  udin [t, r, c] <filename> [o] <output name>"
  echo "  t -> Transpile Udin source to Python."
  echo "  r -> Run Udin source."
  echo "  c -> Compile Udin source."
  echo "  o -> Output.\n"
  error("Expected an argument.")