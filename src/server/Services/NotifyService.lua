local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)

local NotifyService = Knit.CreateService {
  Name = "NotifyService",
  Client = {
    globalMessage = Knit.CreateSignal(),
    personalMessage = Knit.CreateSignal(),
  },
}

function NotifyService:KnitInit()
  self.previousGlobalMessage = nil
  self.personalMessages = {}
end

function NotifyService:KnitStart()
  Players.PlayerRemoving:Connect(function(player)
    self.personalMessages[player.Name] = nil
  end)
end

function NotifyService:NotifyGlobal(message)
  self.previousGlobalMessage = message

  game:SetAttribute("globalMessage", message)
  self.Client.globalMessage:FireAll(message)
end

function NotifyService:NotifyPlayer(player: Player, message)
  player:SetAttribute("personalMessage", message)
  
  self.personalMessages[player.Name] = message
  self.Client.personalMessage:Fire(player, message)
end

function NotifyService.Client:GetGlobalMessage()
  return self.previousGlobalMessage
end

function NotifyService.Client:GetPersonalMessage(player: Player)
  return self.personalMessages[player.Name]
end