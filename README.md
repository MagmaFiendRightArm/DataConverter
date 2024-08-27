## What it does

- Turns Roblox instances into tables
- Turns tables back into Roblox instances
- Works with:
  - Vector3
  - CFrame
  - Color3
  - BrickColor
  - NumberSequence
  - ColorSequence

## How to use it

```lua
local DataConverter = require(path.to.DataConverter)

local myInstance = game.Workspace.SomeObject
local tableData = DataConverter.ToTable(myInstance)

local newInstance = DataConverter.ToInstance(tableData, "Part")
