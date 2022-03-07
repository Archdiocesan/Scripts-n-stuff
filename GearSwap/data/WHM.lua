function get_sets()    
    -- Load and initialize the include file.
    include('Sel-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
	state.Buff['Divine Caress'] = buffactive['Divine Caress'] or false
	
	
	state.AutoCaress 			= M(true, 'Auto Caress Mode')
	state.Gambanteinn			= M(false, 'Gambanteinn Cursna Mode')
	state.BlockLowDevotion 		= M(true, 'Block Low Devotion')
	state.AutoBuffMode 		  	= M{['description'] = 'Auto Buff Mode','Auto','Off'}
	state.AutoSubMode 		 	= M(true, 'Auto Sublimation Mode')
	state.AutoWSMode		 	= M(true, 'Auto Weaponskill Mode')
	autowstp = 1000
	autows = 'Spirit Taker'
	autofood = 'Rolan. Daifuku'
	


	init_job_states({"AutoDefenseMode","AutoWSMode","Capacity","AutoNukeMode"},{"AutoBuffMode","IdleMode","Passive","TreasureMode"})
	
	function handle_smartcure(cmdParams)
		if cmdParams[2] then
			if tonumber(cmdParams[2]) then
				cureTarget = windower.ffxi.get_mob_by_id(tonumber(cmdParams[2]))
			else
				cureTarget = table.concat(cmdParams, ' ', 2)
				cureTarget = get_closest_mob_by_name(cureTarget) 
				if not cureTarget.name then cureTarget = player.target end
				if not cureTarget.name then cureTarget = player end
			end
		elseif player.target.type == "SELF" or player.target.type == 'MONSTER' or player.target.type == 'NONE' then
			cureTarget = player
		else
			cureTarget = player.target
		end

		if cureTarget.status == 2 or cureTarget.status == 3 then
			windower.chat.input('/ma "Arise" '..cureTarget..'')
			return
		end
		
		local missingHP
		local spell_recasts = windower.ffxi.get_spell_recasts()

		if cureTarget.type == 'MONSTER' then
			if silent_can_use(4) and spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			elseif spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif cureTarget.in_alliance then
			cureTarget.hp = find_player_in_alliance(cureTarget.name).hp
			local est_max_hp = cureTarget.hp / (cureTarget.hpp/100)
			missingHP = math.floor(est_max_hp - cureTarget.hp)
		else
			local est_current_hp = 1800 * (cureTarget.hpp/100)
			missingHP = math.floor(1800 - est_current_hp)
		end

		if missingHP < 250 then
			if spell_recasts[1] < spell_latency then
				windower.chat.input('/ma "Cure" '..cureTarget.id..'')
			elseif spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif missingHP < 400 then
			if spell_recasts[2] < spell_latency then
				windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			elseif spell_recasts[1] < spell_latency then
				windower.chat.input('/ma "Cure" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif missingHP < 900 then
			if spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif missingHP < 1400 then
			if spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[6] < spell_latency then
				windower.chat.input('/ma "Cure VI" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		else
			if spell_recasts[6] < spell_latency then
				windower.chat.input('/ma "Cure VI" '..cureTarget.id..'')
			elseif spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.

function job_filtered_action(spell, eventArgs)

end

function job_pretarget(spell, spellMap, eventArgs)

end

function job_precast(spell, spellMap, eventArgs)

	if spell.action_type == 'Magic' then
		if spellMap == 'StatusRemoval' and not (spell.english == "Erase" or spell.english == "Esuna" or spell.english == "Sacrifice") then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if abil_recasts[32] < latency and not silent_check_amnesia() and state.AutoCaress.value then
				eventArgs.cancel = true
				windower.chat.input('/ja "Divine Caress" <me>')
				windower.chat.input:schedule(1,'/ma "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end
	elseif spell.type == 'JobAbility' then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		if spell.english == 'Devotion' and state.BlockLowDevotion.value and abil_recasts[28] < latency and player.hpp < 75 then
			eventArgs.cancel = true
			add_to_chat(123,'Abort: Blocking Devotion under 75% HP to prevent inefficient use.')
		end
	end
		
	if state.CastingMode.value == 'Proc' then
		classes.CustomClass = 'Proc'
	end
end

function job_post_precast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		
		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if sets.MaxTP and get_effective_player_tp(spell, WSset) > 3200 then
				equip(sets.MaxTP[spell.english] or sets.MaxTP)
			end
		end
	end
end

function job_post_midcast(spell, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if spellMap == 'StatusRemoval' then
		if state.Buff['Divine Caress'] then
			equip(sets.buff['Divine Caress'])
		end
		if spell.english == 'Cursna' then
			if (player.sub_job == 'NIN' or player.sub_job == 'DNC') and sets.midcast.DWCursna then
				equip(sets.midcast.DWCursna)
			elseif state.Gambanteinn.value and item_available('Gambanteinn') then
				equip({main="Gambanteinn"})
			end
		end
		
	elseif spellMap == 'BarElement' then
		if (state.Buff['Light Arts'] or state.Buff['Addendum: White']) and sets.midcast.BarElement and sets.midcast.BarElement.LightArts then
			equip(sets.midcast.BarElement.LightArts)
		end
    elseif spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
        if state.MagicBurstMode.value ~= 'Off' then equip(sets.MagicBurst) end
		if spell.element == world.weather_element or spell.element == world.day_element then
			if state.CastingMode.value == 'Fodder' then
				if spell.element == world.day_element then
					if item_available('Zodiac Ring') then
						sets.ZodiacRing = {ring2="Zodiac Ring"}
						equip(sets.ZodiacRing)
					end
				end
			end
		end
		
		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end
    end
	
end

function job_aftercast(spell, spellMap, eventArgs)
    if not spell.interrupted then
        if state.UseCustomTimers.value and spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
            state.MagicBurstMode:reset()
			if state.DisplayMode.value then update_job_states()	end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
		if default_spell_map == 'Curaga' then
			if world.weather_element == 'Light' then
				return 'LightWeatherCuraga'
			elseif world.day_element == 'Light' then
				return 'LightDayCuraga'	
			end
		elseif default_spell_map == 'Cure' then
			if state.Weapons.value ~= 'None' then
				if state.Buff['Afflatus Solace'] then
					if world.weather_element == 'Light' then
						return '"MeleeLightWeatherCureSolace'
					elseif world.day_element == 'Light' then
						return 'MeleeLightDayCureSolace'
					else
						return "MeleeCureSolace"
					end
				elseif world.weather_element == 'Light' then
					return 'MeleeLightWeatherCure'
				elseif world.day_element == 'Light' then
					return 'MeleeLightDayCure'
				else
					return 'MeleeCure'
				end
			elseif state.Buff['Afflatus Solace'] then
				if world.weather_element == 'Light' then
					return 'LightWeatherCureSolace'
				elseif world.day_element == 'Light' then
					return 'LightDayCureSolace'
				else
					return "CureSolace"
				end
			elseif world.weather_element == 'Light' then
                return 'LightWeatherCure'
			elseif world.day_element == 'Light' then
                return 'LightDayCure'
			end
		elseif spell.skill == "Enfeebling Magic" then
			if spell.english:startswith('Dia') then
				return "Dia"
            elseif spell.type == "WhiteMagic" or spell.english:startswith('Frazzle') or spell.english:startswith('Distract') then
                return 'MndEnfeebles'
            else
                return 'IntEnfeebles'
            end
        end
    end
end


function job_customize_idle_set(idleSet)
    if buffactive['Sublimation: Activated'] then
        if (state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere')) and sets.buff.Sublimation then
            idleSet = set_combine(idleSet, sets.buff.Sublimation)
        elseif state.IdleMode.value:contains('DT') and sets.buff.DTSublimation then
            idleSet = set_combine(idleSet, sets.buff.DTSublimation)
        end
    end

    if state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere') then
		if player.mpp < 51 then
			if sets.latent_refresh then
				idleSet = set_combine(idleSet, sets.latent_refresh)
			end
			
			if (state.Weapons.value == 'None' or state.UnlockWeapons.value) and idleSet.main then
				local main_table = get_item_table(idleSet.main)

				if  main_table and main_table.skill == 12 and sets.latent_refresh_grip then
					idleSet = set_combine(idleSet, sets.latent_refresh_grip)
				end
				
				if player.tp > 10 and sets.TPEat then
					idleSet = set_combine(idleSet, sets.TPEat)
				end
			end
		end
   end
	
    return idleSet
end

-- Called by the 'update' self-command.
-- function job_update(cmdParams, eventArgs)
	-- if cmdParams[1] == 'user' then check_arts() end
-- end


-- Function to display the current relevant user state when doing an update.
-- function display_current_job_state(eventArgs)
    -- display_current_caster_state()
    -- eventArgs.handled = true
-- end

    -- Allow jobs to override this code
function job_self_command(commandArgs, eventArgs)
	if commandArgs[1]:lower() == 'smartcure' then
		handle_smartcure(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'elemental' then
		handle_elemental(commandArgs)
		eventArgs.handled = true
	end
end

function job_tick()
	-- if check_arts() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end

function check_arts()
	if buffup ~= '' or (not data.areas.cities:contains(world.area) and ((state.AutoArts.value and player.in_combat) or state.AutoBuffMode.value ~= 'Off')) then
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if abil_recasts[29] < latency and not state.Buff['Afflatus Solace'] and not state.Buff['Afflatus Misery'] then
			send_command('@input /ja "Afflatus Solace" <me>')
			tickdelay = os.clock() + 1
			return true

		elseif player.sub_job == 'SCH' and not (state.Buff['SJ Restriction'] or arts_active()) and abil_recasts[228] < latency then
			send_command('@input /ja "Light Arts" <me>')
			tickdelay = os.clock() + 1
			return true
		end
		
	end

	return false
end

function handle_elemental(cmdParams)
    -- cmdParams[1] == 'elemental'
    -- cmdParams[2] == ability to use

    if not cmdParams[2] then
        add_to_chat(123,'Error: No elemental command given.')
        return
    end
    local command = cmdParams[2]:lower()

	if command == 'spikes' then
		windower.chat.input('/ma "'..data.elements.spikes_of[state.ElementalMode.value]..' Spikes" <me>')
		return
	elseif command == 'enspell' then
		windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..'" <me>')
		return
	--Leave out target, let shortcuts auto-determine it.
	elseif command == 'weather' then
		if player.sub_job == 'RDM' then
			windower.chat.input('/ma "Phalanx" <me>')
		else
			local spell_recasts = windower.ffxi.get_spell_recasts()
			if (player.target.type == 'SELF' or not player.target.in_party) and buffactive[data.elements.storm_of[state.ElementalMode.value]] and not buffactive['Klimaform'] and spell_recasts[287] < spell_latency then
				windower.chat.input('/ma "Klimaform" <me>')
			else
				windower.chat.input('/ma "'..data.elements.storm_of[state.ElementalMode.value]..'"')
			end
		end
		return
	end

	local target = '<t>'
	if cmdParams[3] then
		if tonumber(cmdParams[3]) then
			target = tonumber(cmdParams[3])
		else
			target = table.concat(cmdParams, ' ', 3)
			target = get_closest_mob_id_by_name(target) or '<t>'
		end
	end

	if command == 'nuke' or command == 'smallnuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
	
		if command == 'nuke' and state.ElementalMode.value == 'Light' then
			local tiers = {'Holy II','Holy','Banish III','Banish II','Banish'}
			for k in ipairs(tiers) do
				if spell_recasts[get_spell_table_by_name(tiers[k]).id] < spell_latency and actual_cost(get_spell_table_by_name(tiers[k])) < player.mp then
					windower.chat.input('/ma "'..tiers[k]..'" '..target..'')
					return
				end
			end
		else
			local tiers = {' II',''}
			for k in ipairs(tiers) do
				if spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
					windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
					return
				end
			end
		end
		add_to_chat(123,'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')
		
	elseif command:contains('tier') then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierlist = {['tier1']='',['tier2']=' II',['tier3']=' III',['tier4']=' IV',['tier5']=' V',['tier6']=' VI'}
		
		windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..tierlist[command]..'" '..target..'')
		
	elseif command == 'ara' then
		windower.chat.input('/ma "'..data.elements.nukera_of[state.ElementalMode.value]..'ra" '..target..'')
		
	elseif command == 'aga' then
		windower.chat.input('/ma "'..data.elements.nukega_of[state.ElementalMode.value]..'ga" '..target..'')
		
	elseif command == 'helix' then
		windower.chat.input('/ma "'..data.elements.helix_of[state.ElementalMode.value]..'helix" '..target..'')
	
	elseif command == 'enfeeble' then
		windower.chat.input('/ma "'..data.elements.elemental_enfeeble_of[state.ElementalMode.value]..'" '..target..'')
	
	elseif command == 'bardsong' then
		windower.chat.input('/ma "'..data.elements.threnody_of[state.ElementalMode.value]..' Threnody" '..target..'')

    else
        add_to_chat(123,'Unrecognized elemental command.')
    end
end

function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not data.areas.cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		for i in pairs(buff_spell_lists[state.AutoBuffMode.Value]) do
			if not buffactive[buff_spell_lists[state.AutoBuffMode.Value][i].Buff] and (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Always' or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Combat' and (player.in_combat or being_attacked)) or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Engaged' and player.status == 'Engaged') or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Idle' and player.status == 'Idle') or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'OutOfCombat' and not (player.in_combat or being_attacked))) and spell_recasts[buff_spell_lists[state.AutoBuffMode.Value][i].SpellID] < spell_latency and silent_can_use(buff_spell_lists[state.AutoBuffMode.Value][i].SpellID) then
				windower.chat.input('/ma "'..buff_spell_lists[state.AutoBuffMode.Value][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
	else
		return false
	end
end

function check_buffup()
	if buffup ~= '' then
		local needsbuff = false
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) then
				needsbuff = true
				break
			end
		end
	
		if not needsbuff then
			add_to_chat(217, 'All '..buffup..' buffs are up!')
			buffup = ''
			return false
		end
		
		local spell_recasts = windower.ffxi.get_spell_recasts()
		
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) and spell_recasts[buff_spell_lists[buffup][i].SpellID] < spell_latency then
				windower.chat.input('/ma "'..buff_spell_lists[buffup][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
		
		return false
	else
		return false
	end
end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	When='Always'},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Always'},
		-- {Name='Haste',			Buff='Haste',		SpellID=57,		When='Idle'},
		-- {Name='Refresh',		Buff='Refresh',		SpellID=109,	When='Always'},
		-- {Name='Stoneskin',		Buff='Stoneskin',	SpellID=54,		When='Always'},
	},
	Default = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=false},
		{Name='Protectra V',	Buff='Protect',		SpellID=129,	Reapply=false},
		{Name='Shellra V',		Buff='Shell',		SpellID=134,	Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		Reapply=false},
		{Name='Stoneskin',		Buff='Stoneskin',	SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',		SpellID=53,		Reapply=false},
		{Name='Haste',			Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	Reapply=false},
		{Name='Auspice',		Buff='Auspice',		SpellID=96,		Reapply=false},
		-- {Name='Boost-STR',		Buff='STR Boost',	SpellID=479,	Reapply=false},
		-- {Name='Barthundra',		Buff='Barthunder',	SpellID=70,		Reapply=false},
		-- {Name='Barparalyzra',	Buff='Barparalyze',	SpellID=88,		Reapply=false},
		-- {Name='Phalanx',		Buff='Phalanx',		SpellID=106,	Reapply=false},
	},
	Melee = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=false},
		{Name='Shellra V',		Buff='Shell',		SpellID=134,	Reapply=false},
		{Name='Protectra V',	Buff='Protect',		SpellID=129,	Reapply=false},
		{Name='Haste',			Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Auspice',		Buff='Auspice',		SpellID=96,		Reapply=false},
	},
}