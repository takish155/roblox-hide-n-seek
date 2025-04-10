local Knit = require(game.ReplicatedStorage.Packages.knit)

local NotifyController = Knit.CreateController {
  Name = "NotifyController"
}

function NotifyController:KnitStart()
  local NotifyService = Knit.GetService("NotifyService")

  self.NotifyService = NotifyService
end

function NotifyController:GetGlobalNotifySignal()
  local NotifyService = Knit.GetService("NotifyService")

  return NotifyService.globalMessage
end

function NotifyController:GetPreviousGlobalMessage()
  local NotifyService = Knit.GetService("NotifyService")
  local success, message = NotifyService:GetGlobalMessage():await()

  return message
end

return NotifyController