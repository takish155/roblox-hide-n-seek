local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.react)

local function HelloWorld(props)
  return React.createElement("ScreenGui", {
    ResetOnSpawn = false,
  }, {
    Label1 = React.createElement("TextLabel", {
      Text = "Hello world!",
      Size = UDim2.new(0, 200, 0, 50),
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      TextColor3 = Color3.fromRGB(0, 0, 0),
    }),

    Label2 = React.createElement("TextLabel", {
      Text = "Hello world xd!",
      Size = UDim2.new(0, 200, 0, 50),
      Position = UDim2.new(0, 0, 0.5, 0),
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      TextColor3 = Color3.fromRGB(0, 0, 0),
    }),
  })
end

return HelloWorld


