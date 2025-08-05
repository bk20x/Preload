# Preload
### Macro to parse Json into tables and generate query functions for them at compile time. 
####  Tested in my game with JNA and multiple types




#### Compile with `--app:lib --passL:-static`
````
macro initData() =
  result = newStmtList()
  const types = staticRead("types.txt").split("\r\n")

  types.each line:
  let split = line.split(',')
  name = split[0] -> strip
  accessor = split[1] -> strip
  file = split[2] -> strip
  registeredTypes.add newCustomType(name,accessor,file)

    if registeredTypes.len == 1:
      echo "Ok, 1 type registered"
    else:
      echo "Ok, ", registeredTypes.len, " types registered"

    let 
      fileData = genSym nskConst 
      table = newIdentNode name
      queryProc = newIdentNode "query" & name
    result.add quote do:
      const `fileData` = staticRead `file`
      let `table` = jsonToTable(`fileData`, `accessor`)
      proc `queryProc`(elementName : cstring): cstring {.cdecl, exportc, dynlib.} = #Exported for dll, so
        return cstring($(`table`[$(elementName)]))
````
> If `types.txt` contained `Item, name, items.json` and 
> an item looked like {"name":"potion"...}
> the macro will generate a procedure `queryItem` and you would retrieve the json object by name `echo queryItem("potion")`
