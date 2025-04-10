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
  self.deathSignal = {}
  self.hiders = {}
  self.seeker = nil
  self.seekerKills = 0

  self.started = false
end

local function handlePlayerDeath(self, player, left)
  local playerRole = player:GetAttribute("role")

  if playerRole ~= "hider" or not self.started then
    return
  end

  player:SetAttribute("role", nil)

  for i, hider in ipairs(self.hiders) do
    if hider.Name == player.Name then
      table.remove(self.hiders, i)
      break
    end
  end

  if not left then
    self.seekerKills += 1
    self.NotifyService:NotifyPlayer(self.seeker, "You have killed " .. player.Name .. "!")
    self.NotifyService:NotifyPlayer(player, "You have been killed by " .. self.seeker.Name .. "!")
  end

  self.deathSignal[player.Name]:Disconnect()
  self.deathSignal[player.Name] = nil

  if #self.hiders == 0 then
    self.GameStateService:EndGame("SEEKER_WIN")
  end
end

local function handlePlayerRemoved(self, player)
  if not self.started then
    return
  end

  local playerRole = player:GetAttribute("role")

  if playerRole == "seeker" then
    self.GameStateService:EndGame("SEEKER_LEAVE")

    return
  end

  if playerRole == "hider" then
    handlePlayerDeath(self, player, true)
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
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid:Humanoid = character:WaitForChild("Humanoid")
    
    self.deathSignal[player.Name] = humanoid.Died:Connect(function()
      handlePlayerDeath(self, player, false)
    end)
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

local function rewardPlayersOnState(self, state)
  local NotifyService = self.NotifyService

  if state == "SEEKER_LEAVE" then
    -- Only reward XP
    NotifyService:NotifyGlobal("Seeker has left the game!")
  end 

  if state == "HIDER_WIN" then
    -- Reward the hiders (more than the seeker)
    NotifyService:NotifyGlobal("Seeker didn't find all the hiders, hiders win!")
  end

  if state == "SEEKER_WIN" then
    -- Reward the seeker (more than the hiders)
    NotifyService:NotifyGlobal("Seeker found all the hiders, seeker wins!")
  end

end

local function gameEndCleanUp(self)
  for _, player in ipairs(Players:GetPlayers()) do
    player:SetAttribute("role", nil)
  end
  --  Disconnect the death signals
  for _, connection in pairs(self.deathSignal) do
    connection:Disconnect()
  end

  self.deathSignal = {}
  self.hiders = {}
  self.seeker = nil
  self.seekerKills = 0
end

function GameLogicService:HandleGameEnd(state)
  if not self.started then
    return
  end
  self.started = false
  
  rewardPlayersOnState(self, state)
  gameEndCleanUp(self)
end

return GameLogicService