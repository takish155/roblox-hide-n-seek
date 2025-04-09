local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.knit)
local Promise = require(ReplicatedStorage.Packages.promise)

local TimerService = Knit.CreateService {
  Name = "TimerService",
  Client = {
    Timer = Knit.CreateSignal()
  },
}

function TimerService:KnitInit()
  self.task = nil
  self.started = nil
  self.length = nil
end

function TimerService:KnitStart()

end

local function clearTimer(self, soft)
  if self.task and not soft then
    self.task:cancel()
    self.task = nil
  end

  self.started = nil
  self.length = nil

  game:SetAttribute("timerStarted", nil)
  game:SetAttribute("timerLength", nil)
end

function TimerService:ClearTimer(message)
  clearTimer(self)

  if message then
    local NotifyService = Knit.GetService("NotifyService")

    NotifyService:NotifyGlobal(message)
  end
end

function TimerService:IntializeTimer(length, callbackFn, message, onTimerFinishMessage)
  self.started = os.time()
  self.length = length
  
  local NotifyService = Knit.GetService("NotifyService")

  if message then
    NotifyService:NotifyGlobal(message)
  end

  game:SetAttribute("timerStarted", self.started)
  game:SetAttribute("timerLength", self.length)

  self.task = Promise.delay(length):andThen(function()
    callbackFn()

    if onTimerFinishMessage then
      NotifyService:NotifyGlobal(onTimerFinishMessage)
    end

    clearTimer(self, true)
  end)
end

function TimerService.Client:GetTimeRemaining()
  if not self.started or not self.length then
    return 0
  end

  local timeElapsed = os.time() - self.started
  local timeRemaining = math.max(0, self.length - timeElapsed)

  return timeRemaining
end