local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)
local GameOptionEnum = require(ReplicatedStorage.Enums.GameOptionEnum)
local GameStateEnum = require(ReplicatedStorage.Enums.GameStateEnum)
local Promise = require(ReplicatedStorage.Packages.promise)

local GameStateService = Knit.CreateService {
  Name = "GameStateService",
  Client = {},
}

function GameStateService:KnitInit()
  self.currentGameState = GameStateEnum.WAITING_FOR_PLAYERS
  game:SetAttribute("gameState", self.currentGameState)

end

local function handlePlayerAdded(self)
  if self.currentGameState ~= GameStateEnum.WAITING_FOR_PLAYERS then
    return
  end

  local playerCount = #Players:GetPlayers()

  if playerCount >= 2 then
    self:StartIntermission()
  end
end

local function handlePlayerRemoving(self)
  if self.currentGameState == GameStateEnum.INTERMISSION then
    local playerCount = #Players:GetPlayers()

    if playerCount < 2 then
      self:EndIntermission()
    end
  end
end

function GameStateService:KnitStart()
  local NotifyService = Knit.GetService("NotifyService")
  
  self:SetGameState(GameStateEnum.WAITING_FOR_PLAYERS)
  NotifyService:NotifyGlobal("Waiting for players...")
  
  Players.PlayerAdded:Connect(function(_)
    handlePlayerAdded(self)
  end)
  
  
  Players.PlayerRemoving:Connect(function(_)
    handlePlayerRemoving(self)
  end)
  
  self.TimerService = Knit.GetService("TimerService")
end

function GameStateService:GetCurrentGameState()
  return self.currentGameState
end

function GameStateService:SetGameState(newGameState)
  self.currentGameState = newGameState
  game:SetAttribute("gameState", newGameState)
end

function GameStateService:CanStartIntermission()
  local playerCount = #Players:GetPlayers()

  return self.currentGameState == GameStateEnum.WAITING_FOR_PLAYERS or
  self.currentGameState == GameStateEnum.GAME_OVER and
  playerCount >= 2
end

function GameStateService:StartIntermission()
  local canStart = self:CanStartIntermission()
  if not canStart then
    return
  end

  self:SetGameState(GameStateEnum.INTERMISSION)

  self.TimerService:IntializeTimer(
    GameOptionEnum.game.intermissionTime, 
    function ()
      self:StartGame()
    end,
    "Intermission"
  )
end

function GameStateService:EndIntermission()
  if self.currentGameState ~= GameStateEnum.INTERMISSION then
    return
  end

  self:SetGameState(GameStateEnum.WAITING_FOR_PLAYERS)
end

function GameStateService:StartGame()
  local playerCount = #Players:GetPlayers() 

  if self.currentGameState ~= GameStateEnum.INTERMISSION then
    return
  end

  if playerCount < 2 then
    self:SetGameState(GameStateEnum.WAITING_FOR_PLAYERS)

    return
  end

  -- Teleport the hiders
  -- Wait
  -- Teleport the seekers

  self:SetGameState(GameStateEnum.IN_PROGRESS)
end

local function endGameAction(self)
  Promise.delay(5):andThen(function ()
    local canStartIntermission = self:CanStartIntermission()
    if not canStartIntermission then
      self:SetGameState(GameStateEnum.WAITING_FOR_PLAYERS)
      return
    end
  
    self:StartIntermission()
  end)
end

function GameStateService:EndGame(state)
  if self.currentGameState ~= GameStateEnum.IN_PROGRESS then
    return
  end
  self:SetGameState(GameStateEnum.GAME_OVER)

  endGameAction(self)
end

return GameStateService