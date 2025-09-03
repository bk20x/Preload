import macros




macro `->`*(t: typedesc): typedesc = t.getType() 



macro each*(collection: untyped, iname: untyped, code: varargs[untyped]) =
  result = newStmtList()
  result.add quote do:
    for `iname` in `collection`:
      `code`

macro pairs*(collection: untyped,kname,vname: untyped, code: varargs[untyped]) =
  result = newStmtList()
  result.add quote do:
    for `kname`, `vname` in `collection`:
      `code`


macro `<-`*(ident, value : untyped) =
  result = newStmtList()
  result.add quote do:
    let `ident` = `value`



macro `->`*(value: untyped, actions: varargs[untyped]): untyped =
  var currentResult = value
  for action in actions:
    if action.kind == nnkStmtListExpr:
      let body = action[0]
      currentResult = quote do:
        let it = `currentResult`
        `body`
    else:
      currentResult = quote do:
        `action` `currentResult`
  result = currentResult

