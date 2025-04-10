local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

Knit.AddControllers(script.Parent.Controllers)

Knit.Start():andThen(function()
  print("Knit started!")
end):catch(warn)
