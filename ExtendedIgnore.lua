local frame = CreateFrame ("Button", "ExtendedIgnoreFrame", UIParent) -- create a Frame (doesnt Matter which one) to start a function
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function (self,event,arg1,...)
	if (event == "ADDON_LOADED" and arg1 =="Blizzard_AchievementUI") then
		load_ignore_table()
	end
	if event == "PLAYER_LOGIN" then
		load_ignore_table()
        hooksecurefunc("ToggleDropDownMenu", BanButtonSetup);
	end
	if event == "PLAYER_LOGOUT" then
		save_ignore_table()
	end
end)


local function myChatFilter(self, event, msg, author, ...)
    --print(event, msg, author)
    if isPlayerInIgnoreTable(author) then
        print("Ignored player found: "..author.."("..msg..")")
        if event == "CHAT_MSG_WHISPER" then
            autoreply(author)
        end
        if event == "CHAT_MSG_WHISPER_INFORM" then
            print("autoreply sent to "..author)
        end
        return true
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", myChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", myChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", myChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", myChatFilter)



SLASH_EXTENTEDIGNORE1 = "/ban"
SlashCmdList["EXTENTEDIGNORE"] = function(msg)
    ban(msg)
end 


function ban(msg)
    local _, _, player, reason = string.find(msg, "(%w+-%w+)(.+)")
    if reason ~= nil then
        reason = trim(reason)
    else
        player = msg
        reason = ""
    end
    --print(msg)
    print(player)
    --print(reason)
    local _, _, playername, playerserver = string.find(player, "(%w+)-(%w+)")
    --print(playername, playerserver)
    --local playercontainer = {["player"] = player, ["reason"] = reason}
    addToIgnoreTable(player, reason)
end

function isPlayerLegit()

end

function autoreply(player)
    msg = L["defaultIgnore"]
    SendChatMessage(msg, "WHISPER", nil, player)
end

function banPlayerPopup(player)
    addToIgnoreTable(player, "TODO")
end

function addToIgnoreTable(player, reason)
    print(player, isPlayerInIgnoreTable(player))
    local msg = ""
    if not isPlayerInIgnoreTable(player) then
        local_ignore_table[player] = reason
        msg = "Player "..player.." banned"
        if reason ~= "" then
            msg = msg.." ("..reason..")."
        end        
    else
        msg = "Player "..player.." is already on your ignore list"
        if reason ~= "" then
            msg = msg.." ("..local_ignore_table[player]..")" 
        end       
    end
    print(msg)
end

function isPlayerInIgnoreTable(playername)
    for k,v in pairs(local_ignore_table) do
        if k == playername then          
            return true
        end
    end
    return false
end

function printIgnoreTable()
    for player, reason in pairs(local_ignore_table) do
        msg = player
        if reason ~= "" then
            msg = msg.." ("..reason..")"
        end
        print(msg)
    end
end

function load_ignore_table()
    local_ignore_table = IgnoreTable
    if local_ignore_table == nil then
        local_ignore_table = {}
    end
end

function save_ignore_table()
    IgnoreTable = local_ignore_table
end

function decline_invite_list()
    
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end



UnitPopupButtons["BAN"] = { text = "Ban", dist = 0 };
table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"]-1, "BAN");
table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["FRIEND"]-1, "BAN");
function BanButtonSetup(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay) -- src: https://eu.battle.net/forums/en/wow/topic/6444795639 // https://worldofwarcraft.com/en-gb/character/eredar/prr
    if dropDownFrame and level then
        local buttonPrefix = "DropDownList" .. level .. "Button";
        local i = 2;
        while (1) do
            local button = _G[buttonPrefix..i];
            if not button then break end;
            if button:GetText() == UnitPopupButtons["BAN"].text then
                button.func = function() banPlayerPopup(_G[buttonPrefix.."1"]:GetText()) end
                break;
            end
            i = i + 1;
        end
    end
end

local b = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	b:SetSize(80 ,22) -- width, height
	b:SetText("ExtendedIgnore")
	b:SetPoint("CENTER")
	b:SetScript("OnClick", function()
		printIgnoreTable()
	end)
    
    
    
