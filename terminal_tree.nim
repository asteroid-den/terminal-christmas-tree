import std/[
  parseopt,
  terminal,
  random,
  os,
  strtabs,
  strutils,
  sequtils,
  sugar,
  enumerate,
  unicode,
  osproc
]

randomize()

let
  BALL = "⏺"
  STAR = "★"
  COLOR = {
    "blue": "\u001B[94m",
    "yellow": "\u001B[93m",
    "cyan": "\u001B[96m",
    "green": "\u001B[92m",
    "magenta": "\u001B[95m",
    "white": "\u001B[97m",
    "red": "\u001B[91m",
  }.newStringTable

converter strToSingleRune(s: string): Rune = s.toRunes[0]

proc randomChangeChar(str: string, value: int): string =
  let indexes = collect(newSeq):
    for i in 1..value: sample((0..(str.len - 1)).toSeq)

  var runes = str.toRunes

  for idx in indexes:
    if $runes[idx] == "_":
      runes[idx] = BALL

  return runes.join()

proc tree(height=13, screenWidth=80): seq[string] =
  let
    h = (if height mod 2 != 0: height + 1 else: height)
    stars = @[STAR, STAR.repeat(3)]
    trunk = "[___]"
    lbegin = "/"
    lend = "\\"
    pattern = "_/"

  var
    middle: string
    body = @["/_\\", "/_\\_\\"]
    j = 5

  for i in countup(7, h, 2):
    middle = pattern.repeat(i + 1 - j)
    body.add(lbegin & middle[0..^2] & lend)
    
    middle = middle.replace("/", "\\")
    body.add(lbegin & middle[0..^2] & lend)

    inc j

  body.add trunk

  result = newSeq[string]()

  for row in stars:
    result.add unicode.alignLeft(unicode.align(row, (screenWidth + row.toRunes.len) div 2), screenWidth)

  for line in body:
    result.add line.center screenWidth

proc balls(tree: seq[string]): seq[string] =
  result = tree

  for idx, x in enumerate(2, tree[0..^4]):
    result[idx] = randomChangeChar(tree[idx], tree[idx].len div 8)

proc coloredStarsBalls(tree: seq[string]): seq[string] =
  var
    doneRow: string


  for idx, row in enumerate(tree):
    doneRow = ""
    for rune in row.runes:
      if $rune == STAR:
        doneRow &= COLOR["yellow"] & STAR & "\u001B[0m"

      elif $rune == BALL:
        doneRow &= sample(COLOR.values.toSeq) & BALL & "\u001B[0m"

      else:
        doneRow &= $rune

    result.add doneRow

proc clearConsole =
  var command: string

  when defined(windows):
    command = "cls"

  else:
    command = "clear"

  discard execCmd command

proc cli =
  var parser = initOptParser(shortNoVal={'t'})

  var
    width = 80
    height = 13
    auto = false

  for kind, key, value in parser.getopt():
    case kind
    of cmdShortOption:
      case key
      of "t":
        (width, height) = terminalSize()
        auto = true

      of "s":
        if not auto:
          height = parseInt value

      of "w":
        if not auto:
          width = parseInt value

    of cmdLongOption:
      case key
      of "terminal":
        (width, height) = terminalSize()
        auto = true

      of "size":
        if not auto:
          height = parseInt value

      of "width":
        if not auto:
          width = parseInt value

    else:
      discard

  while true:
    sleep int rand(0.1..1.0) * 1000
    clearConsole()
    echo coloredStarsBalls(balls(tree(height, width))).join("\n")

setControlCHook proc {.noconv.} =
  clearConsole()
  echo "\n" & "Merry Christmas!!".center(terminalWidth()) & "\n\n"
  quit()

when isMainModule:
  cli()
