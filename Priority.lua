local frame = nil;

local function FindUnitBuff(unit, buffname)
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i);
        if (name == nil) then
            return;
        end
        if (name == buffname) then
            local leftTime = 0;
            if (expirationTime) then
                leftTime = expirationTime - GetTime()
            end
            return icon, count, duration, leftTime;
        end
    end
    return nil;
end

local function GetProtectionPaladinPriorityForLowHealth()
    local start, duration = GetSpellCooldown("수호자의 빛");
    local leftTime = start + duration - GetTime();
    if (leftTime <= 0) then
        return GetSpellTexture("수호자의 빛");
    end

    local start, duration = GetSpellCooldown("헌신적인 수호자");
    local leftTime = start + duration - GetTime();
    if (leftTime <= 0) then
        return GetSpellTexture("헌신적인 수호자");
    end

    local start, duration = GetSpellCooldown("고대 왕의 수호자");
    local leftTime = start + duration - GetTime();
    if (leftTime <= 0) then
        return GetSpellTexture("고대 왕의 수호자");
    end

    local start, duration = GetSpellCooldown("신의 축복");
    local leftTime = start + duration - GetTime();
    if (leftTime <= 0) then
        return GetSpellTexture("신의 축복");
    end
end

local function GetProtectionPaladinPriority()
    local health = UnitHealth("player");
    local healthMax = UnitHealthMax("player");
    if healthMax ~= 0 and health / healthMax < 0.5 then
        return GetProtectionPaladinPriorityForLowHealth();
    end

    local icon, _, _, timeLeft = FindUnitBuff("player", "정의의 방패");
    if (icon == nil or timeLeft < 0.5) then
        local currentCharges = GetSpellCharges("정의의 방패")
        if (currentCharges > 0) then
            return GetSpellTexture("정의의 방패");
        end
    end

    local leftTime = GetTotemTimeLeft(1);
    if (leftTime < 2) then
        return GetSpellTexture("신성화");
    end

    local currentCharges = GetSpellCharges("심판")
    if (currentCharges > 0) then
        return GetSpellTexture("심판");
    end

    local start, duration = GetSpellCooldown("응징의 방패");
    local leftTime = start + duration - GetTime();
    if (leftTime <= 0) then
        return GetSpellTexture("응징의 방패");
    end

    local currentCharges = GetSpellCharges("축복받은 망치")
    if (currentCharges > 0) then
        return GetSpellTexture("축복받은 망치");
    end

    return nil
end

local function OnUpdate()
    local unitClass = UnitClass("player");
    local spec = GetSpecialization();
    local specName = ""
    if spec then
        _, specName = GetSpecializationInfo(spec)
    end

    local icon = nil;
    if unitClass == "성기사" and specName == "보호" then
        icon = GetProtectionPaladinPriority();
    end

    if (icon ~= nil) then
        frame.icon:SetTexture(icon);
        frame.icon:Show();
    else
        frame.icon:Hide();
    end
end

frame = CreateFrame("Frame", "Priority", UIParent);
frame:SetPoint("CENTER", 0, 150);
frame:SetWidth(50);
frame:SetHeight(50);
frame:SetAlpha(0.5);
frame.icon = frame:CreateTexture();
frame.icon:SetPoint("CENTER");
frame.icon:SetWidth(50);
frame.icon:SetHeight(50);
frame.icon:Hide();
frame:SetScript("OnUpdate", OnUpdate);
frame:Show()
