local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)
local GameOptionEnum = require(ReplicatedStorage.Enums.GameOptionEnum)
local GameStateEnum = require(ReplicatedStorage.Enums.GameStateEnum)

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
  self.TimerService = Knit.GetService("TimerService")

  Players.PlayerAdded:Connect(function(_)
    handlePlayerAdded(self)
  end)


  Players.PlayerRemoving:Connect(function(_)
    handlePlayerRemoving(self)
  end)
end

function GameStateService:GetCurrentGameState()
  return self.currentGameState
end

function GameStateService:SetGameState(newGameState)
  self.currentGameState = newGameState
  game:SetAttribute("gameState", newGameState)
end

function GameStateService:StartIntermission()
  local playerCount = #Players:GetPlayers()

  if 
      self.currentGameState ~= GameStateEnum.WAITING_FOR_PLAYERS and
      self.currentGameState ~= GameStateEnum.GAME_OVER and
      playerCount < 2
    then
      
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

function GameStateService:EndGame()
  if self.currentGameState ~= GameStateEnum.IN_PROGRESS then
    return
  end
  self:SetGameState(GameStateEnum.GAME_OVER)

  -- Teleport the players back to the lobby
  -- Reward the players
  -- Start the intermission again
end

return GameStateService