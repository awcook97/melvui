mq = require('mq')
require 'ImGui'
local FailSafe = function()
	--mq.delay(1)
end
local openGUI = true
local shouldDrawGUI = true

local dotGUI = function()
    openGUI, shouldDrawGUI = ImGui.Begin('DoTs', openGUI)
	local checkDebuff = function (buffName)
		if (mq.TLO.Target.Buff(buffName).ID()) then
			local buffTimer = mq.TLO.Target.Buff(buffName).Duration.TotalSeconds()
			local buffCaster = mq.TLO.Target.Buff(buffName).Caster()
			ImGui.Text(buffName..' - '..buffCaster..' - '..buffTimer)
		end
	end
	local checkSpecDebuff = function (className, buffName, altName)
		if (mq.TLO.Me.Class.ShortName() == className) then
			if (mq.TLO.Target.Buff(buffName).ID()) then
				local buffTimer = mq.TLO.Target.Buff(buffName).Duration.TotalSeconds()
				local buffCaster = mq.TLO.Target.Buff(buffName).Caster()
				ImGui.Text(altName..' - '..buffCaster..' - '..buffTimer)
			end
		end
	end
	local debuffsTakenUp = 0
    if shouldDrawGUI then
		if (mq.TLO.Target.ID()) then
			checkDebuff('Funeral Dirge')
			checkDebuff('T`Vyl\'s Resolve')
			checkDebuff('Mana Burn')
			checkSpecDebuff('SHD', 'Bloodletting Coalition', 'Coalition')
			checkSpecDebuff('BRD', 'Coalition of Sticks and Stones', 'Coalition')
			checkSpecDebuff('ROG', 'Pinpoint Shortcomings', 'Pinpoint Defects')
			if (mq.TLO.Target.Slowed.ID()) then ImGui.Text('Slowed! '..mq.TLO.Target.Slowed()) end
			local freeBuffs = 94 - mq.TLO.Target.BuffCount()
			if (mq.TLO.Target.Type() == 'NPC') then ImGui.Text('Buffs Free '..freeBuffs) end
		end
        ImGui.End()
    end
end

local targetGUI = function()
    openGUI, shouldDrawGUI = ImGui.Begin('Target', openGUI)
    if shouldDrawGUI then
        local pctHPs = mq.TLO.Target.PctHPs()
        if not pctHPs then pctHPs = 0 end
        local ratioHPs = pctHPs / 100
		local pctAggro = mq.TLO.Target.PctAggro()
		if not pctAggro then pctAggro = 0 end
		local tLevel = mq.TLO.Target.Level()
		if not tLevel then tLevel = 0 end
		local tType = mq.TLO.Target.Type()
		if not tType then tType = 'none' end
        local myName = mq.TLO.Target.CleanName()
		if not myName then myName = 'None' end

        if (mq.TLO.Target.Type() == 'NPC') then
			ImGui.PushStyleColor(ImGuiCol.PlotHistogram, ratioHPs, 0, 1 - ratioHPs, 1) 
			ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
		else
			ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1- ratioHPs, ratioHPs, 0.6, 1)
			ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1)
		end
        ImGui.ProgressBar(ratioHPs, -1, -1, tLevel..' '..myName..': '..pctHPs..'%'..'Aggro: '..pctAggro..'%')
        ImGui.PopStyleColor(2)

        ImGui.End()
    end
end

local hpGUI = function()
	WindowFlags = ImGuiWindowFlags.NoTitleBar
    openGUI, shouldDrawGUI = ImGui.Begin('HP', openGUI, WindowFlags)
    if shouldDrawGUI then
        local pctHPs = mq.TLO.Me.PctHPs()
        if not pctHPs then pctHPs = 0 end
        local ratioHPs = pctHPs / 100
		
        local myName = mq.TLO.Me.CleanName()
		if (mq.TLO.Me.AmIGroupLeader()) then myName = '*L*'..myName end
		if (mq.TLO.Group.GroupSize()) then
			if (mq.TLO.Group.MainAssist() == mq.TLO.Me()) then myName = '*MA*'..myName end
			if (mq.TLO.Group.MainTank() == mq.TLO.Me()) then myName = '*MT*'..myName end
			if (mq.TLO.Group.MasterLooter() == mq.TLO.Me()) then myName = '*ML*'..myName end
		end
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1- ratioHPs, ratioHPs, 0.6, 1)
        ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1)
        ImGui.ProgressBar(ratioHPs, -1, -0, myName..': '..pctHPs..'%')
        ImGui.PopStyleColor(2)
		DiscTimer()
		-- Tank Buffs
		CheckSpecBuff('SHD', 'Shining Aegis', 'Shining Aegis')
		CheckSpecBuff('PAL', 'Shining Aegis', 'Shining Aegis')
		CheckSpecBuff('WAR', 'Shining Aegis', 'Shining Aegis')
		CheckSpecSongYes('SHD', 'Lich Sting', 'SK Epic')
		CheckSpecSongYes('PAL', 'Lich Sting', 'SK Epic')
		CheckSpecSongYes('WAR', 'Lich Sting', 'SK Epic')
		CheckSpecSongYes('SHD', 'Group Armor of the Inquisitor', 'Group Armor')
		CheckSpecSongYes('PAL', 'Group Armor of the Inquisitor', 'Group Armor')
		CheckSpecSongYes('WAR', 'Group Armor of the Inquisitor', 'Group Armor')
		CheckSpecBuffYes('SHD', 'Glyph of Dragon Scales', 'Dragon Glyph')
		CheckSpecBuffYes('PAL', 'Glyph of Dragon Scales', 'Dragon Glyph')
		CheckSpecBuffYes('WAR', 'Glyph of Dragon Scales', 'Dragon Glyph')
		-- SK Buffs
		CheckSpecBuff('SHD', 'Cadcane\'s Skin', 'Cadcane\'s Skin')
		CheckSpecBuff('SHD', 'Stormwall Stance', 'Stormwall Stance')
		CheckSpecBuff('SHD', 'Confluent Disruption', 'Confluent Disruption')
		CheckSpecBuff('SHD', 'Shroud of the Restless', 'SK Unity')
		-- PAL Buffs
		CheckSpecBuff('PAL', 'Stormwall Stance', 'Stormwall Stance')
		-- BRD Buffs
		CheckSpecBuff('BRD', 'Symphony of Battle', 'Symphony of Battle')
		CheckSpecSongYes('BRD', 'Ruaabri\'s Fury', 'Ruaabris Fury')
		CheckSpecSongYes('BRD', 'Dichotomic Fury', 'BST Dicho')
		CheckSpecSongYes('BRD', 'Dissident Fury', 'BST Dicho')
		CheckSpecSongYes('BRD', 'Composite Fury', 'BST Dicho')
		CheckSpecSongYes('BRD', 'Quick Time', 'QT')
		CheckSpecSongYes('BRD', 'Prophet\'s Gift of the Ruchu', 'Shaman Epic')
		
		-- General
		CheckBuff('Kromrif Focusing')
		CheckSpecBuffYes(mq.TLO.Me.Class.ShortName(), 'Glyph of Destruction', 'Destruction Glyph')
		ImGui.Text('Buffs Free: '..mq.TLO.Me.FreeBuffSlots())
        ImGui.End()
    end
end

local groupGUI = function()
	local WindowFlags = ImGuiWindowFlags.NoBackground
	--if (not mq.TLO.Group.GroupSize()) then WindowFlags = ImGuiWindowFlags.NoBackground end
    openGUI, shouldDrawGUI = ImGui.Begin('Group', openGUI, WindowFlags)
	if shouldDrawGUI then
		local groupSize = mq.TLO.Group.GroupSize()
		if not groupSize then groupSize = 0 end
		if (groupSize > 0) then
			for i=1,groupSize
			do
				PushGroupHP(i)
			end
		end
		ImGui.End()
	end
end

local manaGUI = function()
	local WindowFlags = ImGuiWindowFlags.NoBackground + ImGuiWindowFlags.NoTitleBar
    openGUI, shouldDrawGUI = ImGui.Begin('MP', openGUI, WindowFlags)
    if shouldDrawGUI then
		local pctMPs = mq.TLO.Me.PctMana()
		if not pctMPs then pctMPs = 0 end
		local ratioMPs = pctMPs / 100

        local myName = mq.TLO.Me.CleanName()

        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1 - ratioMPs, ratioMPs, 1, 1)
        ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)
        ImGui.ProgressBar(ratioMPs, -1, -1, pctMPs..'%')
        ImGui.PopStyleColor(2)


        ImGui.End()
    end
end

local endGUI = function()
	local WindowFlags = ImGuiWindowFlags.NoBackground + ImGuiWindowFlags.NoTitleBar
    openGUI, shouldDrawGUI = ImGui.Begin('Endurance', openGUI, WindowFlags)
    if shouldDrawGUI then
        local pctHPs = mq.TLO.Me.PctHPs()
        if not pctHPs then pctHPs = 0 end
		local pctMPs = mq.TLO.Me.PctMana()
		if not pctMPs then pctMPs = 0 end
		local pctEnd = mq.TLO.Me.PctEndurance()
		if not pctEnd then pctEnd = 0 end
        local ratioHPs = pctHPs / 100
		local ratioMPs = pctMPs / 100
		local ratioEnd = pctEnd / 100

        local myName = mq.TLO.Me.CleanName()

        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, ratioEnd, 1, 0.4, 1)
        ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)
        ImGui.ProgressBar(ratioEnd, -1, -1, pctEnd..'%')
        ImGui.PopStyleColor(2)


        ImGui.End()
    end
end

function PushGroupHP(groupNum)
	local gMemName = mq.TLO.Group.Member(groupNum).Name()
	local pctHPs = mq.TLO.Group.Member(groupNum).Spawn.PctHPs()
	local pctMPs = mq.TLO.Group.Member(groupNum).Spawn.PctMana()
	local pctEnd = mq.TLO.Group.Member(groupNum).Spawn.PctEndurance()
	if not pctHPs then pctHPs = 0 end
	if not pctMPs then pctMPs = 0 end
	if not pctEnd then pctEnd = 0 end
	if (mq.TLO.Group.Member(groupNum).Present()) then
		local ratioHPs = pctHPs / 100
		local ratioMPs = pctMPs / 100
		local ratioEnd = pctEnd / 100

		ImGui.Columns(3)
		PushHP(ratioHPs, pctHPs, gMemName)
		ImGui.NextColumn()
		PushMP(ratioMPs, pctMPs, gMemName)
		ImGui.NextColumn()
		PushEnd(ratioEnd, pctEnd, gMemName)
		ImGui.Columns(1)
	else
		if not gMemName then return end
		PushHP(0, gMemName, 'Not In Zone')
	end
end

function PushHP(ratioHPs, pctHPs, gMemName)
	local gDisplayName = gMemName
	--if (mq.TLO.Group.MainAssist() == gMemName) then gDisplayName = '*MA*'..gDisplayName end
	--if (mq.TLO.Group.MainTank() == gMemName) then gDisplayName = '*MT*'..gDisplayName end
	--if (mq.TLO.Group.MasterLooter() == gMemName) then gDisplayName = '*ML*'..gDisplayName end
	ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1- ratioHPs, ratioHPs, 0.6, 1)
	ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1)
	ImGui.ProgressBar(ratioHPs, -1, -0, gDisplayName..': '..pctHPs..'%')
	ImGui.PopStyleColor(2)
	if (ImGui.IsItemClicked()) then
		mq.TLO.Group.Member(gMemName).Spawn.DoTarget()
	end
end

function PushMP(ratioMPs, pctMPs, gMemName)
	ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 1 - ratioMPs, ratioMPs, 1, 1)
	ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)
	ImGui.ProgressBar(ratioMPs, -0.5, -0, pctMPs..'%')
	ImGui.PopStyleColor(2)
	if (ImGui.IsItemClicked()) then
		mq.TLO.Group.Member(gMemName).Spawn.DoTarget()
	end
end

function PushEnd(ratioEnd, pctEnd, gMemName)
	ImGui.PushStyleColor(ImGuiCol.PlotHistogram, ratioEnd, 1, 0.4, 1)
	ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)
	ImGui.ProgressBar(ratioEnd, -1, 0, pctEnd..'%')
	ImGui.PopStyleColor(2)
	if (ImGui.IsItemClicked()) then
		mq.TLO.Group.Member(gMemName).Spawn.DoTarget()
	end
end

function DiscTimer()
	if (mq.TLO.Me.ActiveDisc.ID()) then
		local discName = mq.TLO.Me.ActiveDisc.Name()
		ImGui.ProgressBar(1, -1, 15, discName)
		if (ImGui.IsItemClicked()) then
			mq.cmd.stopdisc()
		end
	end
end

function CheckBuff(buffName)
	if (not mq.TLO.Me.Buff(buffName).ID()) then
		ImGui.Text('Need - '..buffName)
	end
end
CheckSpecBuff = function (className, buffName, buffText)
	if (mq.TLO.Me.Class.ShortName() == className) then
		if (not mq.TLO.Me.Buff(buffName).ID()) then
			ImGui.Text('Need - '..buffText)
		end
	end
end
CheckSpecBuffYes = function (className, buffName, buffText)
	if (mq.TLO.Me.Class.ShortName() == className) then
		if (mq.TLO.Me.Buff(buffName).ID()) then
			ImGui.Text('Have - '..buffText)
		end
	end
end
CheckSpecSongYes = function (className, buffName, buffText)
	if (mq.TLO.Me.Class.ShortName() == className) then
		if (mq.TLO.Me.Song(buffName).ID()) then
			ImGui.Text('Have - '..buffText)
		end
	end
end

mq.imgui.init('dotGUI', dotGUI)
mq.imgui.init('targetGUI', targetGUI)
mq.imgui.init('hpGUI', hpGUI)
mq.imgui.init('groupGUI', groupGUI)
mq.imgui.init('manaGUI', manaGUI)
mq.imgui.init('endGUI', endGUI)
local terminate = false
while not terminate do
    FailSafe()
    mq.delay(100) -- equivalent to '1s'
end