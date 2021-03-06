require("item_ability/item_pipe")
alreadyCached = {}

pairedAbility = {
    shredder_chakram = "shredder_return_chakram",
    shredder_chakram_2 = "shredder_return_chakram_2",
    morphling_replicate = "morphling_morph_replicate",
    elder_titan_ancestral_spirit = "elder_titan_return_spirit",
    phoenix_icarus_dive = "phoenix_icarus_dive_stop",
    phoenix_sun_ray = "phoenix_sun_ray_stop",
    phoenix_fire_spirits = "phoenix_launch_fire_spirit",
    abyssal_underlord_dark_rift = "abyssal_underlord_cancel_dark_rift",
    alchemist_unstable_concoction = "alchemist_unstable_concoction_throw",
    naga_siren_song_of_the_siren = "naga_siren_song_of_the_siren_cancel",
    rubick_telekinesis = "rubick_telekinesis_land",
    bane_nightmare = "bane_nightmare_end",
    ancient_apparition_ice_blast = "ancient_apparition_ice_blast_release",
    lone_druid_true_form = "lone_druid_true_form_druid",
    nyx_assassin_burrow = "nyx_assassin_unburrow",
    wisp_tether = "wisp_tether_break",
    wisp_spirits = "wisp_spirits_in",
    morphling_morph_agi = "morphling_morph",
    morphling_morph_str = "morphling_morph",
    pangolier_gyroshell = "pangolier_gyroshell_stop",
    tiny_craggy_exterior = "tiny_toss_tree",
    dawnbreaker_celestial_hammer = "dawnbreaker_converge",
    hoodwink_sharpshooter = "hoodwink_sharpshooter_release"
}

-- 卖技能的面板中不显示这些技能
hideAbility = {
	["damage_counter"] = true,
	["attribute_bonus"] = true,
	["attribute_bonus_lua"] = true,
	["keeper_of_the_light_illuminate_end"] = true,
	["keeper_of_the_light_spirit_form_illuminate"] = true,
	["morphling_morph_replicate"] = true,
	["shredder_return_chakram"] = true,
	["shredder_return_chakram_2"] = true,
	["shredder_return_chakram_lua"] = true,
	["shredder_return_chakram_2_lua"] = true,
	["elder_titan_return_spirit"] = true,
	["phoenix_icarus_dive_stop"] = true,
	["phoenix_sun_ray_stop"] = true,
	["phoenix_launch_fire_spirit"] = true,
	["abyssal_underlord_cancel_dark_rift"] = true,
	["alchemist_unstable_concoction_throw"] = true,
	["naga_siren_song_of_the_siren_cancel"] = true,
	["rubick_telekinesis_land"] = true,
	["bane_nightmare_end"] = true,
	["ancient_apparition_ice_blast_release"] = true,
	["lone_druid_true_form_druid"] = true,
	["nyx_assassn_unburrow"] = true,
	["morphling_morph"] = true,
	["nyx_assassin_unburrow"] = true,
	["pangolier_gyroshell_stop"] = true,
	["tiny_toss_tree"] = true,
	["generic_hidden"] = true,
	["wisp_tether_break"] = true,
	["wisp_spirits_in"] = true,
	["wisp_spirits_out"] = true,
	["ability_capture"] = true,
	["dawnbreaker_converge"] = true,
	["hoodwink_sharpshooter_release"] = true,
};

brokenModifierCounts = {
    modifier_shadow_demon_demonic_purge_charge_counter = 3,
    modifier_bloodseeker_rupture_charge_counter = 2,
    modifier_earth_spirit_stone_caller_charge_counter = 6,
    modifier_ember_spirit_fire_remnant_charge_counter = 3,
    modifier_obsidian_destroyer_astral_imprisonment_charge_counter = 1
}

brokenModifierAbilityMap = {
    shadow_demon_demonic_purge = "modifier_shadow_demon_demonic_purge_charge_counter",
    bloodseeker_rupture = "modifier_bloodseeker_rupture_charge_counter",
    earth_spirit_stone_caller = "modifier_earth_spirit_stone_caller_charge_counter",
    ember_spirit_fire_remnant = "modifier_ember_spirit_fire_remnant_charge_counter",
    obsidian_destroyer_astral_imprisonment = "modifier_obsidian_destroyer_astral_imprisonment_charge_counter"
}

noReturnAbility = {    --不退回升级点数的技能
    puck_ethereal_jaunt = true,
    beastmaster_call_of_the_wild_boar = true,
    beastmaster_call_of_the_wild_hawk = true,
    troll_warlord_whirling_axes_ranged = true,
    troll_warlord_whirling_axes_melee = true,
    lone_druid_savage_roar_bear = true,
    phoenix_sun_ray_toggle_move = true,
    morphling_hybrid = true,
    morphling_morph_agi = true,
    morphling_morph_str = true,
    morphling_adaptive_strike_agi = true,
    morphling_adaptive_strike_str = true,
    dawnbreaker_converge = true,
    hoodwink_sharpshooter_release = true
}

meleeMap = {
-- Remap troll ulty
-- troll_warlord_berserkers_rage = 'troll_warlord_berserkers_rage_melee'
}

manualActivate = {
    keeper_of_the_light_recall_lua = true
}

local unitList = LoadKeyValues('scripts/npc/npc_units_custom.txt')
-- Contains info on heroes
local heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')

local meleeList = {}
for heroName, values in pairs(heroListKV) do
    if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' then
        if values.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK' then
            meleeList[heroName] = true
        end
    end
end


-- Tells you if a given heroName is melee or not
local function isMeleeHero(heroName)
    if meleeList[heroName] then
        return true
    end

    return false
end


function unitExists(unitName)
    -- Check if the unit exists
    if unitList[unitName] then return true end
    return false
end

function CHoldoutGameMode:HeroListRefill()
    self._vHeroList = {}
    for heroName, abilityKV in pairs(self.AbilitiesKV) do
        for _, ability in pairs(abilityKV) do
            self._vHeroList[ability] = "npc_dota_hero_"..heroName
        end
    end
end

function GetPlayerAbilityNumber(hero)
	local abilityNumber = 0
	for i = 0, 30 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local abilityName = ability:GetAbilityName()
            if hideAbility[abilityName] ~= true and not string.match(abilityName, "special_bonus_") then
                print(abilityName)
                abilityNumber = abilityNumber + 1
            end
        end
	end
	return abilityNumber
end

function CHoldoutGameMode:AddAbility(keys)
    --PrintTable(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        local abilityName = keys.abilityName
        if hero then
            removeAllGenericHiddenAbility(hero)
            --hero:RemoveAbility("generic_hidden")
            local maxSlotNumber = 6
            if hero:HasModifier("modifier_extra_slot_9_consume") then
                maxSlotNumber = 9
            elseif hero:HasModifier("modifier_extra_slot_8_consume") then
                maxSlotNumber = 8
            elseif hero:HasModifier("modifier_extra_slot_7_consume") then
                maxSlotNumber = 7
            end
            
            local p = hero:GetAbilityPoints()
            if keys.enough == 1 and keys.abilityCost <= p and GetPlayerAbilityNumber(hero) < maxSlotNumber then
                if isMeleeHero(hero:GetUnitName()) and meleeMap[abilityName] then
                    abilityName = meleeMap[abilityName]
                end
                hero:AddAbility(abilityName)
                if pairedAbility[abilityName] ~= nil then
                    hero:AddAbility(pairedAbility[abilityName])
                    if pairedAbility[abilityName] == "nyx_assassin_unburrow" then
                        hero:FindAbilityByName("nyx_assassin_unburrow"):SetLevel(1)  --默认升一级
                    end
                end

                if manualActivate[abilityName] then  --激活光法的两个技能
                    local ab = hero:FindAbilityByName(abilityName)
                    if ab then
                        ab:SetActivated(true)
                    end
                end
                ------------------------------------------------
                if CHoldoutGameMode._vHeroList[abilityName] ~= nil then
                    if alreadyCached[CHoldoutGameMode._vHeroList[abilityName]] == true then
                    else
                        alreadyCached[CHoldoutGameMode._vHeroList[abilityName]] = true
                        print('Precaching unit: ' .. CHoldoutGameMode._vHeroList[abilityName])
                        if unitExists('npc_precache_' .. CHoldoutGameMode._vHeroList[abilityName]) then
                            PrecacheUnitByNameAsync('npc_precache_' .. CHoldoutGameMode._vHeroList[abilityName], function() end)
                        else
                            print('Failed to precache unit: npc_precache_' .. CHoldoutGameMode._vHeroList[abilityName])
                        end
                    end
                else
                    PrecacheUnitByNameAsync('npc_precache_' .. abilityName, function() end)    --自定义的技能需要单独加载
                end
                ------------------------------------------------------
                hero:SetAbilityPoints(p - keys.abilityCost)
                local ability = hero:FindAbilityByName(abilityName)
                ability:SetLevel(1)
                ability:SetHidden(false)
                
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateAbilityList", keys)
                EmitSoundOn("General.Buy", PlayerResource:GetPlayer(keys.playerId))
                if brokenModifierAbilityMap[abilityName] ~= nil then
                    local modifier = hero:FindModifierByName(brokenModifierAbilityMap[abilityName])
                    if modifier then
                        local stack = brokenModifierCounts[brokenModifierAbilityMap[abilityName]]
                        modifier:SetStackCount(stack)
                    end
                end
            else
                Notifications:Bottom(keys.playerId, { text = "#not_enough_ability_points", duration = 2, style = { color = "Red" } })
                EmitSoundOn("General.Cancel", PlayerResource:GetPlayer(keys.playerId))
            end
            if hero:HasModifier("modifier_pipe_1_datadriven") and not hero:HasModifier("modifier_pipe_2_datadriven") then --处理烟斗
                local keys = {}
                keys.caster = hero
                keys.level = 1
                EquipPipe(keys)
            end
            if hero:HasModifier("modifier_pipe_2_datadriven") then
                local keys = {}
                keys.caster = hero
                keys.level = 2
                EquipPipe(keys)
            end

        end
        --ReportHeroAbilities(hero)
    end
end

function CHoldoutGameMode:LevelUpAttribute(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        keys.heroName = false
        if hero then
            local p = hero:GetAbilityPoints()
            if keys.enough == 1 and p > 0 then
                if hero:HasAbility("attribute_bonus_lua") then
                    local level = hero:FindAbilityByName("attribute_bonus_lua"):GetLevel()
                    level = level + 1
                    hero:FindAbilityByName("attribute_bonus_lua"):SetLevel(level)
                else
                    hero:AddAbility("attribute_bonus_lua")
                    hero:FindAbilityByName("attribute_bonus_lua"):SetLevel(1)  --默认升一级
                end
                ------------------------------------------------------
                hero:SetAbilityPoints(p - 1)
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateAbilityList", keys)
                EmitSoundOn("General.Buy", PlayerResource:GetPlayer(keys.playerId))
            else
                Notifications:Bottom(keys.playerId, { text = "#not_enough_ability_points", duration = 2, style = { color = "Red" } })
                EmitSoundOn("General.Cancel", PlayerResource:GetPlayer(keys.playerId))
            end
        end
    end
end


function CHoldoutGameMode:PointToGold(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        keys.heroName = false
        if hero then
            local p = hero:GetAbilityPoints()
            if keys.enough == 1 and p > 0 then
                hero:ModifyGold(1400, true, 0)
                hero:SetAbilityPoints(p - 1)
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateAbilityList", keys)
                EmitSoundOn("General.CoinsBig", PlayerResource:GetPlayer(keys.playerId))
            else
                Notifications:Bottom(keys.playerId, { text = "#not_enough_ability_points", duration = 2, style = { color = "Red" } })
                EmitSoundOn("General.Cancel", PlayerResource:GetPlayer(keys.playerId))
            end
        end
    end
end


function CHoldoutGameMode:RemoveAbility(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        if hero then
            local ability = hero:FindAbilityByName(keys.abilityName)
            if ability then
                local abilityLevel = ability:GetLevel()
                if noReturnAbility[ability:GetAbilityName()] ~= nil then  --同时升级的技能不退技能点
                    abilityLevel = 1
                end
                local pointsReturn = keys.abilityCost + abilityLevel - 1
                local expense = PlayerResource:GetLevel(keys.playerId) * pointsReturn * 30
                if expense > 0 and hero:HasModifier("modifier_item_mulberry") then  --如果有桑葚效果
                    local modifier = hero:FindModifierByName("modifier_item_mulberry")
                    local stack_count = modifier:GetStackCount()
                    if stack_count == 1 then
                        hero:RemoveModifierByName("modifier_item_mulberry")
                        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateFreeToSell", { free = false, playerId = keys.playerId })
                    else
                        modifier:SetStackCount(stack_count - 1)
                    end
                    expense = 0  --卖技能不要钱
                end
                if (hero:GetGold() >= expense) then
                    local abilityLevel = ability:GetLevel()
                    local modifiers = hero:FindAllModifiers()
                    for _, modifier in pairs(modifiers) do
                        if modifier:GetAbility() == ability then
                            modifier:Destroy()
                        end
                    end
                    print(hero:GetUnitName() .. " removing ability: " .. keys.abilityName)
                    hero:RemoveAbility(keys.abilityName)
                    hero:AddAbility("generic_hidden")
                    if pairedAbility[keys.abilityName] ~= nil then
                        hero:RemoveAbility(pairedAbility[keys.abilityName])
                        hero:AddAbility("generic_hidden")
                        print(hero:GetUnitName() .. " removing pairs ability: " .. keys.abilityName)
                    end
                    local p = hero:GetAbilityPoints()
                    hero:SetAbilityPoints(p + pointsReturn)
                    hero:SpendGold(expense, DOTA_ModifyGold_Unspecified)
                    --7.07 更新导致后台删除技能无法在前台立即生效，主动将删除技能的名字推送至前台作处理
                    keys.deleteAbilityName = keys.abilityName
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdatePlayerAbilityList", keys)
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateAbilityList", { heroName = false, playerId = keys.playerId })
                    EmitSoundOn("compendium_points", PlayerResource:GetPlayer(keys.playerId))
                else
                    Notifications:Bottom(keys.playerId, { text = "#you_need", duration = 3, style = { color = "Red" } })
                    Notifications:Bottom(keys.playerId, { text = tostring(expense) .. " ", duration = 3, style = { color = "Red" }, continue = true })
                    Notifications:Bottom(keys.playerId, { text = "#gold_to_sell_this_spell", duration = 3, style = { color = "Red" }, continue = true })
                    EmitSoundOn("General.Cancel", PlayerResource:GetPlayer(keys.playerId))
                end
            end
        end
        ReportHeroAbilities(hero)
    end
end


function CHoldoutGameMode:GrantCourierAbility(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        keys.heroName = false
        if hero then
            local p = hero:GetAbilityPoints()
            if keys.enough == 1 and p > 0 then
                local item = CreateItem(keys.item, hero, hero)
                item:SetPurchaser(hero)
                AddItem(hero, item)
                hero:SetAbilityPoints(p - 1)
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId), "UpdateAbilityList", keys)
            else
                Notifications:Bottom(keys.playerId, { text = "#not_enough_ability_points", duration = 2, style = { color = "Red" } })
                EmitSoundOn("General.Cancel", PlayerResource:GetPlayer(keys.playerId))
            end
        end
    end
end


function removeAllGenericHiddenAbility(hHero)
    while (hHero:HasAbility("generic_hidden"))
    do
        hHero:RemoveAbility("generic_hidden")
    end
end