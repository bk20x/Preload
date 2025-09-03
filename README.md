## Parse JSON arrays into key-value tables based on a defined schema and generate accessor procs for them at compile time.

### Define a schema by creating a types.txt, and for each JSON file you would write *Name*, *Accessor*, *File* \n

#### *Name* generates proc `get,Name`(key: cstring): cstring

#### *Accessor* being the named field of the object you wish to store by its value

#### *File* being the filepath relative to the cwd of the nim compiler




### Compile with `--app:lib --passL:-static`
````
import tables, json, more_sugar, strutils, macros


type
    CustomType = object
      name,accessor,filePath: string

var registeredTypes {.compileTime.}: seq[CustomType] 


func newCustomType(name, accessor, filePath : string): --> CustomType =
  CustomType(name : name, accessor : accessor, filePath : filePath)

proc jsonToTable(jsonData, accessor : string): Table[string,JsonNode] =
  result = initTable[string,JsonNode]()
  data <- parseJson jsonData
  data.elems.each elem:
    accessTag <- unescape ($elem[accessor])
    result[accessTag] = elem

  
macro initData() =
  result = newStmtList()
  const types = staticRead("types.txt").split("\r\n")
  
  types.each line:
    let
       split = line.split(',')
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
      proc `queryProc`(elementName : cstring): cstring {.cdecl, exportc, dynlib.} = #Exported for so, dll
        return cstring($(`table`[$(elementName)]))

initData()
proc NimMain() {.cdecl, importc.}
proc libraryInit() {.exportc, dynlib, cdecl.} =
  NimMain()
````

#### If `types.txt` contained `Item, name, items.json` and an item looked like {"name":"potion", "rarity":"COMMON"}: the macro will generate a procedure `queryItem` and you would retrieve the json object by "name" on the object 
