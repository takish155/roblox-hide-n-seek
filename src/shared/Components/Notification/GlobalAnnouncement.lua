local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local Knit = require(ReplicatedStorage.Packages.knit)

local NotifyController = Knit.GetController("NotifyController")
local previousMessage = NotifyController:GetPreviousGlobalMessage()
print(previousMessage)

local function GlobalAnnouncement()
  local message, setMessage = React.useState(previousMessage)
  
  React.useEffect(function ()
    local GlobalNotifySignal = NotifyController:GetGlobalNotifySignal()

    local conn = GlobalNotifySignal:Connect(function (newMessage) 
      setMessage(newMessage)
    end)

    return function ()
      conn:Disconnect()
    end
  end, {})

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 0.1, 0),
    BackgroundTransparency = 0.7,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),

  }, {
    Text = React.createElement("TextLabel", {
      Text = message,
      Size = UDim2.new(0.7, 0, 1, 0),
      AnchorPoint = Vector2.new(0.5, 0),
      Position = UDim2.new(0.5, 0, 0, 0),
      BackgroundTransparency = 1,
      TextScaled = true,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      Font = Enum.Font.GothamBold,
    })
  })
end

return GlobalAnnouncement