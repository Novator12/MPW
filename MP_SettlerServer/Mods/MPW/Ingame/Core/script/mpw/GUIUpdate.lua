--------------------------------------------------------------------------------
-- added technology param and return values to this function, to be easyer overwritten
--------------------------------------------------------------------------------
function GUIUpdate_HeroAbility( _Ability, _Button, _Technology )
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local SelectedEntityID = GUI.GetSelectedEntity()
	
	if Logic.IsHero(SelectedEntityID) == 1 then
		SelectedEntityID = HeroSelection_GetCurrentSelectedHeroID()	
	end
	
	local RechargeTime = Logic.HeroGetAbilityRechargeTime(SelectedEntityID, _Ability)
	local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(SelectedEntityID, _Ability)
	
	if TimeLeft == RechargeTime then
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,0,0,0,0)
		
		local PlayerID = GUI.GetPlayerID()
		local TechState = 2
		
		if _Technology then
			TechState = Logic.GetTechnologyState(PlayerID, _Technology)
		end
		
		--Building is interdicted
		if TechState == 0 then
			XGUIEng.DisableButton(_Button,1)
		
		--Building is not available yet or Technology is to far in the futur
		elseif TechState == 1 or TechState == 5 then
			XGUIEng.DisableButton(_Button,1)
			
		--Building is enabled and visible	
		elseif TechState == 2 or TechState == 3 or TechState == 4 then
			XGUIEng.DisableButton(_Button,0)
		
		end
		
	elseif TimeLeft < RechargeTime then
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,214,44,24,189)
		XGUIEng.DisableButton(_Button,1)
	end
	
	XGUIEng.SetProgressBarValues(CurrentWidgetID,TimeLeft, RechargeTime)
end