import std/terminal

proc toString*(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

proc error*(msg: string) =
  stdout.styledWriteLine(
    styleBright, fgRed, "Error: ",
    resetStyle, msg
  )
  quit(1)

proc warn*(msg: string) =
  stdout.styledWriteLine(
    styleBright, fgYellow, "Warning: ",
    resetStyle, msg
  )

proc info*(msg: string) =
  stdout.styledWriteLine(
    styleBright, fgCyan, "Info: ",
    resetStyle, msg
  )