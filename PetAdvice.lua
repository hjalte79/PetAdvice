
local function handler(msg, editbox)
 if msg == 'bye' then
  print('Goodbye, World! /wave');
 end
 

 AantalBattlePetsFilter, PlayerAmountOfPets = C_PetJournal.GetNumPets()
 -- print(PlayerAmountOfPets)
 if UnitIsBattlePet("target") then
	
	-- vullen met standaard waarden
	PETTYPES = 11
	targetStrongAgainst = {}
	targetWeakAgainst = {}
	targetPetAbility = {}
	for i=1, PETTYPES do
      targetPetAbility[i] = 0
	  targetStrongAgainst[i] = 0
    end
	

	
	TAB = "   "
	abilityTypes = {
		"Humanoid",		--1
		"Dragonkin",	--2
		"Flying",		--3
		"Undead",		--4
		"Critter",		--5	
		"Magic",		--6
		"Elemental",	--7
		"Beast",		--8
		"Aquatic", 		--9
		"Mechanical"	--10
	}
	
	speciesID = UnitBattlePetSpeciesID("target")
	speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
	idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID)
	
	print("  ")
	print(speciesName .. " (type: " .. abilityTypes[petType] .. " )" )
	
	targetIdTable = idTable
	targetPetType = petType
	
	
	for i, abilityID in pairs(idTable) do
		name, icon, AbilityType = C_PetJournal.GetPetAbilityInfo(abilityID)		
		targetPetAbility[AbilityType] = targetPetAbility[AbilityType] + 1
	end
	
	
	targetStrongAgainst[2] = targetPetAbility[1]
	targetStrongAgainst[6] = targetPetAbility[2]
	targetStrongAgainst[9] = targetPetAbility[3]
	targetStrongAgainst[1] = targetPetAbility[4]
	targetStrongAgainst[4] = targetPetAbility[5]
	targetStrongAgainst[3] = targetPetAbility[6]
	targetStrongAgainst[10] = targetPetAbility[7]
	targetStrongAgainst[5] = targetPetAbility[8]
	targetStrongAgainst[7] = targetPetAbility[9]
	targetStrongAgainst[8] = targetPetAbility[10]
	
	
	targetWeakAgainst[8] = targetPetAbility[1]
	targetWeakAgainst[4] = targetPetAbility[2]
	targetWeakAgainst[2] = targetPetAbility[3]
	targetWeakAgainst[9] = targetPetAbility[4]
	targetWeakAgainst[1] = targetPetAbility[5]
	targetWeakAgainst[10] = targetPetAbility[6]
	targetWeakAgainst[5] = targetPetAbility[7]
	targetWeakAgainst[3] = targetPetAbility[8]
	targetWeakAgainst[6] = targetPetAbility[9]
	targetWeakAgainst[7] = targetPetAbility[10]
	
	print(TAB .. "Strong against:")
	for i, strengthLevel in pairs(targetStrongAgainst) do
		if targetStrongAgainst[i] > 0 then
			print(TAB .. TAB .. abilityTypes[i] .. "(" .. targetStrongAgainst[i] .. ")")
		end
	
	end

	print(TAB .. "Weak against:")
	for i, strengthLevel in pairs(targetWeakAgainst) do
		if targetWeakAgainst[i] > 0 then
			print(TAB .. TAB .. abilityTypes[i] .. "(" .. targetWeakAgainst[i] .. ")")
		end
	
	end
	print(TAB)
	
	
	petTable = {}
	bestStrengthLevel = 0
	for petIndex = 1,AantalBattlePetsFilter do
		local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(petIndex)
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petID)
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID)
		local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesID)
		-- user pet information
		
		
		-- higher rarity = higer ranking		
		petTable[petIndex] = rarity
		
		-- acc to http://www.warcraftpets.com/wow-pet-battles/ types are better against other types
		-- here pets ranking points for types of pets
		petTable[petIndex] = petTable[petIndex] + getPointsByPetType(petType, targetPetType)
		
		-- here pets lose rangking points because target abbilitys from target pet
		for i, targetAbilityID in pairs(targetIdTable) do
			name, icon, targetAbilityType = C_PetJournal.GetPetAbilityInfo(targetAbilityID)		
			petTable[petIndex] = petTable[petIndex] - getPointsByPetAbility(targetAbilityType, petType )		
		end
		
		-- here pets get rangking points because abbilitys from pet
		for i, abilityID in pairs(targetIdTable) do
			name, icon, abilityType = C_PetJournal.GetPetAbilityInfo(abilityID)		
			petTable[petIndex] = petTable[petIndex] + getPointsByPetAbility(abilityType, targetPetType )
		end
		
		if petTable[petIndex] > bestStrengthLevel then
			bestStrengthLevel = petTable[petIndex]
		end
	end
	
	for petIndex, strengthLevel in pairs(petTable) do
		local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(petIndex)
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petID)
		local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID)
		
		if level == 25 and strengthLevel >= bestStrengthLevel and health > 0 then
			DEFAULT_CHAT_FRAME:AddMessage(strengthLevel .. " \124cffffffff\124Hbattlepet:" .. speciesID .. ":0:0:0:0:0:0:0:0\124h[" .. speciesName .. "]\124h\124r " .. abilityTypes[petType] );
		end
	end
	--]]
	print(TAB)
 else
	print("taregt is NOT a BattlePet")
 end
 
 -- why is this line here?
 aantalPetInBattle = C_PetBattles.GetNumPets(1)
end

function getPointsByPetType(userPetType, targetPetType)
	a = -3 -- very very bad
	b = -2 -- very bad
	c = -1 -- bad
	d = 0 -- neutral
	e = 1 -- good
	f = 2 -- beter
	g = 3 -- best
	
	petTypeStrongVsWeak = {}
	--						   1 2 3 4 5 6 7 8 9 0
	petTypeStrongVsWeak[1]  = {d,f,d,b,d,d,d,c,d,d}
	petTypeStrongVsWeak[2]  = {b,d,e,c,d,f,d,d,d,d}
	petTypeStrongVsWeak[3]  = {d,c,d,d,d,b,d,e,f,d}
	petTypeStrongVsWeak[4]  = {f,e,d,d,b,d,d,d,c,d}
	petTypeStrongVsWeak[5]  = {c,d,d,f,d,d,e,b,d,d}
	petTypeStrongVsWeak[6]  = {d,b,f,d,d,d,d,d,e,c}
	petTypeStrongVsWeak[7]  = {d,d,d,d,c,b,d,d,d,g}
	petTypeStrongVsWeak[8]  = {e,d,d,d,f,d,d,c,d,b}
	petTypeStrongVsWeak[9]  = {d,d,b,e,d,c,f,d,d,d}
	petTypeStrongVsWeak[10] = {d,e,d,d,d,d,a,f,d,d}
	-- petTypeStrongVsWeak[yourpet][targetpet]
	
	return petTypeStrongVsWeak[userPetType][targetPetType]

end

function getPointsByPetAbility(attackingAbilityType, defendingPetType )
	c = -2 -- bad
	d = 0 -- neutral
	e = 2 -- good
	
	petAbilityStrongVsWeak = {}
	--						      1 2 3 4 5 6 7 8 9 0
	petAbilityStrongVsWeak[1]  = {d,e,d,d,d,d,d,c,d,d}
	petAbilityStrongVsWeak[2]  = {d,d,d,c,d,e,d,d,d,d}
	petAbilityStrongVsWeak[3]  = {d,c,d,d,d,d,d,d,e,d}
	petAbilityStrongVsWeak[4]  = {e,d,d,d,d,d,d,d,c,d}
	petAbilityStrongVsWeak[5]  = {c,d,d,e,d,d,d,d,d,d}
	petAbilityStrongVsWeak[6]  = {d,d,e,d,d,d,d,d,d,c}
	petAbilityStrongVsWeak[7]  = {d,d,d,d,c,d,d,d,d,e}
	petAbilityStrongVsWeak[8]  = {d,d,c,d,e,d,d,d,d,d}
	petAbilityStrongVsWeak[9]  = {d,d,d,d,d,c,e,d,d,d}
	petAbilityStrongVsWeak[10] = {d,d,d,d,d,d,c,e,d,d}

	return petAbilityStrongVsWeak[attackingAbilityType][defendingPetType]
end


-- http://wowwiki.wikia.com/wiki/Creating_a_slash_command
SLASH_PETADVICE1, SLASH_PETADVICE2 = '/petadvice', '/pa';
SlashCmdList["PETADVICE"] = handler;

