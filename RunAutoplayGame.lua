-- RunAutoplayGame.lua
-- Lua 5.1.4
-- "C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\CivilizationV" %command% -Automation RunAutoplayGame.lua

-- Load the debug library for debugging information
print("Checking if Debug library is loaded...")
if not debug then
    print("Debug library not found")
else
    print("Debug library found")
end

require("debug")

-- Print a message to indicate the script has started
print("Autoplay script started")

-- Define a hook function to be called on function calls for debugging purposes
local function hook(event)
    if event == "call" then
        local info = debug.getinfo(2)
        if info.name then
            print("Called function:", info.name)
        end
    end
end

-- Set the hook function to be called on function calls
debug.sethook(hook, "c")

-- Trigger the start game event
print("Triggering start game event...")
Events.SerialEventStartGame()

-- Add a listener to the SequenceGameInitComplete event
Events.SequenceGameInitComplete.Add(function()
    print("Game init is complete. Starting automation")
    -- Close the load screen
    print("Closing load screen...")
    Events.LoadScreenClose()
    print("Load screen closed")
    -- Print out the UI object for debugging purposes
    print("UI object", UI)
end)

-- Define the EndTurn function to automatically end the turn
local function EndTurn(maxRetries, retries)
    -- Set retries to 0 if it is not provided
    retries = retries or 0
    if Players[Game.GetActivePlayer()]:IsTurnActive() then
        -- Send the "end turn" hotkey
        print("Sending end turn hotkey...")
        UI.SendHotkey("b")
        -- Print a message to indicate that the turn has ended automatically
        print("Turn ended automatically")
        -- Remove and add the event listener again
        print("Removing and adding EndTurn event listener...")
        Events.GameCoreEventPublishComplete.Remove(EndTurn)
        Events.GameCoreEventPublishComplete.Add(EndTurn)
    elseif retries < maxRetries then
        -- If the turn is not active, wait for 1 second before trying again
        print("Waiting for turn to become active...")
        os.sleep(1000)
        -- Retry with incremented retries
        EndTurn(maxRetries, retries + 1)
    else
        -- If the max number of retries has been exceeded, give up
        print("Max retries exceeded. Giving up.")
    end
end

-- Add a listener to the GameCoreEventPublishComplete event
if Events.GameCoreEventPublishComplete then
    print("Adding listener for GameCoreEventPublishComplete event...")
    Events.GameCoreEventPublishComplete.Add(function()
        -- Set the pause player and AI autoplay
        print("Setting pause player and AI autoplay...")
        Game.SetPausePlayer(-1)
        print("Pause player set")
        Game.SetAIAutoPlay(1, -1)
        print("AI autoplay set")
        -- Automatically end the turn, retrying up to 10 times
        EndTurn(10)
        print("End turn called")

        -- Check if notification system and UI agree about ending turn
        print("Checking if notification system and UI agree about ending turn...")
        local canEndTurn = UI.CanEndTurn()
        local notification = Players[Game.GetActivePlayer()]:GetEndTurnBlockingNotification()
        if canEndTurn ~= notification then
            print("Notification system and UI disagree about ending turn")
        end

-- Check if active player's turn is active
if not Players[Game.GetActivePlayer()]:IsTurnActive() then
    print("Active player's turn is not active")
end

-- Print debugging information
print("StackTrace:\n", debug.traceback())
local success, errorMsg = pcall(function()
    print("Contents of canEndTurn table:")
    printTable(canEndTurn)
end)
if not success then
    print("Error occurred while printing canEndTurn table:", errorMsg)
end

-- Print state of game and variables for debugging purposes
print("Game state:")
print("Active player:", Game.GetActivePlayer())
print("Current turn:", Game.GetGameTurn())
print("Current era:", Game.GetEra())
print("Current game speed:", Game.GetGameSpeedType())
print("Current game mode:", Game.GetGameMode())
print("Current map size:", Map.GetWorldSize())
print("Current map type:", Map.GetMapType())
end)
end

-- Define functions to handle the additional events for debugging purposes
local function OnSerialEventGameMessagePopup(message)
print("Message popup:", message)
end

local function OnGameplayAlertMessage(message)
print("Alert message:", message)
end

local function OnGameplaySetActivePlayer(playerID)
print("Active player changed to:", playerID)
end

local function OnRemotePlayerTurnEnd(playerID, turn)
print("Remote player turn ended. Player ID:", playerID, "Turn:", turn)
end

if Events.GameCoreEventPublishComplete then
    print("Listening for GameCoreEventPublishComplete")
    Events.GameCoreEventPublishComplete.Add(OnGameCoreEventPublishComplete)
end

print("Listening for SerialEventGameMessagePopup")
Events.SerialEventGameMessagePopup.Add(function()
    print("Received SerialEventGameMessagePopup event")
end)

print("Listening for GameplayAlertMessage")
Events.GameplayAlertMessage.Add(function()
    print("Received GameplayAlertMessage event")
end)

print("Listening for GameplaySetActivePlayer")
Events.GameplaySetActivePlayer.Add(function()
    print("Received GameplaySetActivePlayer event")
end)

print("Listening for RemotePlayerTurnEnd")
Events.RemotePlayerTurnEnd.Add(function()
    print("Received RemotePlayerTurnEnd event")
end)
