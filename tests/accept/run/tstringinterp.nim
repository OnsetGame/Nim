discard """
  file: "tstringinterp.nim"
  output: "Hello Alice, 64 | Hello Bob, 10"
"""

import macros, parseutils, strutils

proc concat(strings: openarray[string]) : string =
  result = newString(0)
  for s in items(strings): result.add(s)

# This will run though the intee
template ProcessInterpolations(e: expr) =
  var 
    s = e[1].strVal
    
  for f in interpolatedFragments(s):
    if f.kind  == ikString:
      addString(f.value)
    else:
      addExpr(f.value)

macro formatStyleInterpolation(e: expr): expr =
  var 
    formatString = ""
    arrayNode = newNimNode(nnkBracket)
    idx = 1

  proc addString(s: string) =
    formatString.add(s)

  proc addExpr(e: expr) =
    arrayNode.add(e)
    formatString.add("$" & $(idx))
    inc idx
    
  ProcessInterpolations(e)

  result = parseExpr("\"x\" % [y]")
  result[1].strVal = formatString
  result[2] = arrayNode

macro concatStyleInterpolation(e: expr): expr =
  var args : seq[PNimrodNode]
  newSeq(args, 0)

  proc addString(s: string)  = args.add(newStrLitNode(s))
  proc addExpr(e: expr)      = args.add(e)

  ProcessInterpolations(e)

  result = newCall("concat", args)

###

proc sum(a, b, c: int): int =
  return (a + b + c)

var 
  alice = "Alice"
  bob = "Bob"
  a = 10
  b = 20
  c = 34

var
  s1 = concatStyleInterpolation"Hello ${alice}, ${sum (a, b, c)}}"
  s2 = formatStyleInterpolation"Hello ${bob}, ${sum (alice.len, bob.len, 2)}"

write(stdout, s1 & " | " & s2)

