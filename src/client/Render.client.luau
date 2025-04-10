local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.knit)

Knit.OnStart():await()


local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local NotificationScreen = require(ReplicatedStorage.Components.Notification.NotificationScreen)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")


ReactRoblox.createRoot(playerGui):render(
  React.createElement(NotificationScreen)
)