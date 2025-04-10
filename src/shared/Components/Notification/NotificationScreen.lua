local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local GlobalAnnouncement = require(ReplicatedStorage.Components.Notification.GlobalAnnouncement)

local function NotificationScreen()
  print("from notification screen")
  return React.createElement("ScreenGui", {
    ResetOnSpawn = false
  }, {
    Global = React.createElement(GlobalAnnouncement)
  })
end

return NotificationScreen