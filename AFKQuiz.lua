local frame = AFKQuiz or CreateFrame("FRAME", "AFKQuiz")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_ADDON")

local function has_value (tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end


local function addQuestions(question, answer, frame)
  local spacing = (#AFKQuizes.default or 0) + 12 * #AFKQuizes.default
  local QnA = {
    ["question"] = question,
    ["answer"] = answer
  }
  print (spacing)
  table.insert(AFKQuizes.default, QnA)
  frame.fontstring = frame:CreateFontString(nil, "ARTWORK")
  frame.fontstring:SetFontObject(ChatFontNormal)
  frame.fontstring:SetText(#AFKQuizes.default .. ") " .. question .. "          " .. answer)
  frame.fontstring:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, - spacing)
end

local function AFKQuiz(self, event, arg1, arg2, arg3, arg4, ...)
  -- addon loaded
  if event == "ADDON_LOADED" then
    if AFKQuizes == nil then
      AFKQuizes = {
        default = {}
      }
      -- hardcoded quiz until main menu is built
    end
    C_ChatInfo.RegisterAddonMessagePrefix("AFKQuiz")
  end
  if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_PARTY" then
    local channel = "PARTY"
    if event == "CHAT_MSG_RAID" then
      channel = "RAID"
    end
  end
end

-- Main ui window
local AFKQuizUI = AFKQuizUI or CreateFrame("frame", "AFKQuizUI")
AFKQuizUI:Hide()
AFKQuizUI:SetBackdrop({
  bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = false, tileSize = 32, edgeSize = 32,
  insets = {left = 11, right = 12, top = 12, bottom = 11}
})
AFKQuizUI:SetWidth(512)
AFKQuizUI:SetHeight(400)
AFKQuizUI:SetPoint("CENTER", UIParent)
AFKQuizUI:EnableMouse(true)
AFKQuizUI:SetMovable(true)
AFKQuizUI:RegisterForDrag("LeftButton")
AFKQuizUI:SetScript("OnDragStart", function(AFKQuizUI) AFKQuizUI:StartMoving() end)
AFKQuizUI:SetScript("OnDragStop", function(AFKQuizUI) AFKQuizUI:StopMovingOrSizing() end)
AFKQuizUI:SetFrameStrata("FULLSCREEN_DIALOG")

AFKQuizUI.question = AFKQuizUI:CreateFontString(nil, "ARTWORK")
AFKQuizUI.question:SetFontObject(ChatFontNormal)
AFKQuizUI.question:SetPoint("TOPLEFT", 30, - 38)
AFKQuizUI.question:SetText("Question")

AFKQuizUI.questionFrame = CreateFrame("EditBox", nil, AFKQuizUI, "InputBoxTemplate")
AFKQuizUI.questionFrame:SetPoint("TOPLEFT", 30, - 60)
AFKQuizUI.questionFrame:SetWidth(150)
AFKQuizUI.questionFrame:SetHeight(5)
AFKQuizUI.questionFrame:SetMovable(false)
AFKQuizUI.questionFrame:SetAutoFocus(false)
AFKQuizUI.questionFrame:SetFontObject(ChatFontNormal)

AFKQuizUI.answer = AFKQuizUI:CreateFontString(nil, "ARTWORK")
AFKQuizUI.answer:SetFontObject(ChatFontNormal)
AFKQuizUI.answer:SetPoint("TOPLEFT", 220, - 38)
AFKQuizUI.answer:SetText("Answer")

AFKQuizUI.answerFrame = CreateFrame("EditBox", nil, AFKQuizUI, "InputBoxTemplate")
AFKQuizUI.answerFrame:SetPoint("TOPLEFT", 220, - 60)
AFKQuizUI.answerFrame:SetWidth(150)
AFKQuizUI.answerFrame:SetHeight(5)
AFKQuizUI.answerFrame:SetMovable(false)
AFKQuizUI.answerFrame:SetAutoFocus(false)
AFKQuizUI.answerFrame:SetFontObject(ChatFontNormal)

AFKQuizUI.submitButton = CreateFrame("button", nil, AFKQuizUI, "UIPanelButtonTemplate")
AFKQuizUI.submitButton:SetPoint("TOPLEFT", 400, - 51)
AFKQuizUI.submitButton:SetText("Add")
AFKQuizUI.submitButton:SetWidth(70  )
AFKQuizUI.submitButton:SetHeight(22)

AFKQuizUI.saveButton = CreateFrame("button", nil, AFKQuizUI, "UIPanelButtonTemplate")
AFKQuizUI.saveButton:SetPoint("BOTTOMLEFT", 400, 20)
AFKQuizUI.saveButton:SetText("Save")
AFKQuizUI.saveButton:SetWidth(70  )
AFKQuizUI.saveButton:SetHeight(22)

-- AFKQuizUI.overview:SetPoint("TOPLEFT", 30, 75)

AFKQuizUI.scrollframe = AFKQuizUI.scrollframe or CreateFrame("ScrollFrame", "ANewScrollFrame", AFKQuizUI, "UIPanelScrollFrameTemplate")

-- create the standard frame which will eventually become the Scroll Frame's scrollchild
-- importantly, each Scroll Frame can have only ONE scrollchild
AFKQuizUI.scrollchild = AFKQuizUI.scrollchild or CreateFrame("Frame") -- not sure what happens if you do, but to be safe, don't parent this yet (or do anything with it)

-- define the scrollframe's objects/elements:
local scrollbarName = AFKQuizUI.scrollframe:GetName()
AFKQuizUI.scrollbar = _G[scrollbarName.."ScrollBar"]
AFKQuizUI.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"]
AFKQuizUI.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"]

-- all of these objects will need to be re-anchored (if not, they appear outside the frame and about 30 pixels too high)
AFKQuizUI.scrollupbutton:ClearAllPoints()
AFKQuizUI.scrollupbutton:SetPoint("TOPRIGHT", AFKQuizUI.scrollframe, "TOPRIGHT", -2, -2)

AFKQuizUI.scrolldownbutton:ClearAllPoints()
AFKQuizUI.scrolldownbutton:SetPoint("BOTTOMRIGHT", AFKQuizUI.scrollframe, "BOTTOMRIGHT", -2, 2)

AFKQuizUI.scrollbar:ClearAllPoints()
AFKQuizUI.scrollbar:SetPoint("TOP", AFKQuizUI.scrollupbutton, "BOTTOM", 0, -2)
AFKQuizUI.scrollbar:SetPoint("BOTTOM", AFKQuizUI.scrolldownbutton, "TOP", 0, 2)

-- now officially set the scrollchild as your Scroll Frame's scrollchild (this also parents AFKQuizUI.scrollchild to AFKQuizUI.scrollframe)
-- IT IS IMPORTANT TO ENSURE THAT YOU SET THE SCROLLCHILD'S SIZE AFTER REGISTERING IT AS A SCROLLCHILD:
AFKQuizUI.scrollframe:SetScrollChild(AFKQuizUI.scrollchild)

-- set AFKQuizUI.scrollframe points to the first frame that you created (in this case, AFKQuizUI)
-- AFKQuizUI.scrollframe:SetAllPoints(AFKQuizUI)
-- AFKQuizUI.scrollframe:SetAllPoints("TOPLEFT", AFKQuizUI, "TOPLEFT", 0, 0)
AFKQuizUI.scrollframe:SetPoint("TOPLEFT", AFKQuizUI, "TOPLEFT", 30, -100)
AFKQuizUI.scrollframe:SetPoint("BOTTOMRIGHT", AFKQuizUI, "BOTTOMRIGHT", 30, 30)


-- now that SetScrollChild has been defined, you are safe to define your scrollchild's size. Would make sense to make it's height > scrollframe's height,
-- otherwise there's no point having a scrollframe!
-- note: you may need to define your scrollchild's height later on by calculating the combined height of the content that the scrollchild's child holds.
-- (see the bit below about showing content).
AFKQuizUI.scrollchild:SetSize(AFKQuizUI.scrollframe:GetWidth(), ( AFKQuizUI.scrollframe:GetHeight() * 2 ))


-- you need yet another frame which will be used to parent your widgets etc to.  This is the frame which will actually be seen within the Scroll Frame
-- It is parented to the scrollchild.  I like to think of scrollchild as a sort of 'pin-board' that you can 'pin' a piece of paper to (or take it back off)
AFKQuizUI.moduleoptions = AFKQuizUI.moduleoptions or CreateFrame("Frame", nil, AFKQuizUI.scrollchild)
AFKQuizUI.moduleoptions:SetAllPoints(AFKQuizUI.scrollchild)

-- a good way to immediately demonstrate the new scrollframe in action is to do the following...

-- create a fontstring or a texture or something like that, then place it at the bottom of the frame that holds your info (in this case AFKQuizUI.moduleoptions)


AFKQuizUI.submitButton:SetScript("OnClick", function(self)
  -- TODO clear input text
  addQuestions(AFKQuizUI.questionFrame:GetText(), AFKQuizUI.answerFrame:GetText(), AFKQuizUI.moduleoptions)
 end)


SLASH_AFKQ1 = "/afkq"
SlashCmdList["AFKQ"] = function(functionName)
  -- local command, arg1, arg2 = strsplit(" ", functionName, 3)
  if AFKQuizUI:IsShown() then
    AFKQuizUI:Hide()
  else
    AFKQuizUI:Show()
  end
end



frame:SetScript("OnEvent", AFKQuiz)
