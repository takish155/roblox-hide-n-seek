local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)
local GameOptionEnum = require(ReplicatedStorage.Enums.GameOptionEnum)
local GameStateEnum = require(ReplicatedStorage.Enums.GameStateEnum)

local GameLogicService = Knit.CreateService {
  Name = "GameLogicService",
  Client = {},
}

function GameLogicService:KnitInit()
  self.hiders = {}
  self.seeker = nil
  self.seekerKills = 0

  self.started = false
end

local function handlePlayerRemoved(self, player)
  if not self.started then
    return
  end

  local playerRole = player:GetAttribute("role")

  if playerRole == "seeker" then
    self.TimerService:ClearTimer("The seeker has left the game!")

    local playerCount = #Players:GetPlayers()

    if playerCount < 2 then
      self.GameStateService:SetGameState(GameStateEnum.WAITING_FOR_PLAYERS)
    end

    return
  end

  if playerRole == "hider" then
    for i, hider in ipairs(self.hiders) do
      if hider.Name == player.Name then
        table.remove(self.hiders, i)
        break
      end
    end

    if #self.hiders >= 1 then
      return

    end

    if self.seekerKills >= 1 then
      -- End game in favor of the seeker
      return
    end

    self.TimerService:ClearTimer("All hiders have left the game!")
    return
  end
end

function GameLogicService:KnitStart()
  self.GameStateService = Knit.GetService("GameStateService")
  self.TimerService = Knit.GetService("TimerService")
  self.NotifyService = Knit.GetService("NotifyService")

  Players.PlayerRemoving:Connect(function (player)
    handlePlayerRemoved(self, player)
  end)

end

local function handleSeeker(self)
  local players = Players:GetPlayers()

  local seekerIndex = math.random(1, #players)
  local seeker = players[seekerIndex]

  seeker:SetAttribute("role", "seeker")

  self.NotifyService:NotifyPlayer(seeker, "You are the seeker!")

  self.TimerService:InitializeTimer(
    GameOptionEnum.game.hidingTime,
    function ()
      -- Give seeker their tool
      -- Give seeker their buffs
      -- Teleport seeker to spawn point
    end,
    "Hiding time has started, find a hiding spot!",
    "Hiding time has ended! Seeker is spawned!"
  )

  self.seeker = seeker
end

local function handleHiders(self)
  local players = Players:GetPlayers()

  for _, player in ipairs(players) do
    if self.seeker.Name == player.Name then
      continue
    end

    player:SetAttribute("role", "hider")

    -- Teleport hider
    -- Give their equipped tool

    self.NotifyService:NotifyPlayer(player, "You are a hider. Find a hiding spot before the seeker finds you!")
  end

  table.insert(self.hiders, players)
end

function GameLogicService:HandleGameStart()
  if self.started then
    return
  end

  self.started = true
  
  handleSeeker(self)
  handleHiders(self)
end