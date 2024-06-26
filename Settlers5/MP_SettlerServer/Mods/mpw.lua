-- MainMenu only
if not MPW then
	local OnInitialize
	local OnGUILoaded
	local OnRuleChanged
	local OnMapStart
	--------------------------------------------------------------------------------
	MPW = {}
	MPW.Log = LuaDebugger.Log or function() end
	MPW.Core = { OnInitialize = function() return true end }
	MPW.Modules = {
		Core = {
			Priority = 0,
			Name = "Core",
			Description = {
				DE = "Schaltet das Multiplayer Workover ein oder aus. @cr Wenn das Kernmodul deaktiviert ist, können auch keine anderen Module geladen werden.",
				GB = "Turns the Multiplayer Workover on or off. @cr If the Core module is deactivated, no other modules can be loaded.",
			},
		},
	}
	--------------------------------------------------------------------------------
	function OnInitialize()
		
		MPW.Log( "MPW: OnInitialize" )
		
		CWidget.Transaction_AddRulePage( "MP_SettlerServer\\Mods\\MPW\\MainMenu\\MPWMenu.xml" )
		Script.Load( "MP_SettlerServer\\Mods\\MPW\\MainMenu\\MPWMenu.lua" )
		
		MPW.LoadModules()
	end
	--------------------------------------------------------------------------------
	function OnGUILoaded()
		
		MPW.Log( "MPW: OnGUILoaded" )
		
		-- init modules
		for name, _ in pairs( MPW.Modules ) do
			if MPW[ name ] and MPW[ name ].OnGUILoaded then
				MPW[ name ].OnGUILoaded()
			end
		end
		
		-- update buttons
		MPW.UpdateModuleButtons()
	end
	--------------------------------------------------------------------------------
	function OnRuleChanged()
		
		MPW.Log("MPW: OnRuleChanged")
		
		-- update buttons
		MPW.UpdateModuleButtons()
	end
	--------------------------------------------------------------------------------
	function OnMapStart()
		
		MPW.Log("MPW: OnMapStart")

		local modules = {}
		local priorities = {}
		
		-- get all modules to be loaded
		for name, mod in pairs( MPW.Modules ) do
			if MPW.IsModuleActive( name ) then
				
				local priority = mod.Priority or 1
				
				if not modules[ priority ] then
					modules[ priority ] = {}
					table.insert( priorities, priority )
				end
				
				table.insert( modules[ priority ], name )
			end
		end
		
		-- sort from lowest to highest priority
		table.sort(
			priorities,
			function( a, b )
				return a < b
			end
		)
		
		-- load module archives
		-- low priority modules will be loaded first and then be overloaded by higher priority modules
		for _, priority in ipairs( priorities ) do
			for _, name in pairs( modules[ priority ] ) do
				
				-- if normal load fails, try load with value as suffix if a module has multiple versions
				if not CMod.PushArchiveRelative("MP_SettlerServer\\Mods\\MPW\\Ingame\\" .. name .. ".bba") then
				
					local value = MPW.GetModuleValue( name )
					CMod.PushArchiveRelative("MP_SettlerServer\\Mods\\MPW\\Ingame\\" .. name .. value .. ".bba")
				end
				
				-- init modules
				if MPW[ name ] and MPW[ name ].OnMapStart then
					MPW[ name ].OnMapStart()
				end
			end
		end
	end
	--------------------------------------------------------------------------------
	function MPW.Activate()
		
		MPW.Log("MPW: Activate")
		MPW.IsActive = true
		
		-- get serverdata
		local d = CustomStringHelper.FromString( XNetwork.EXTENDED_GameInformation_GetCustomString() )
		
		-- set some keys
		CustomStringHelper.SetKey( d, "CHAIN_CONSTRUCTION" ) -- can still be deactivated
		CustomStringHelper.SetKey( d, "DCAoEDamage" )
		CustomStringHelper.SetKey( d, "LogicAoEDamage" )
		-- reset some keys
		CustomStringHelper.ResetKey( d, "L2RifleFix" )
		CustomStringHelper.ResetKey( d, "RELOAD_FIX" )
		CustomStringHelper.ResetKey( d, "LEADER_TAKES_IT_ALL" )
		CustomStringHelper.ResetKey( d, "SWFS" )
		CustomStringHelper.ResetKey( d, "SW" )
		
		-- send serverupdate
		XNetwork.EXTENDED_GameInformation_SetCustomString( CustomStringHelper.ToString( d ) )
		
		----------------------------------------------------------------------------
		
		-- kill action funcs of some rule buttons
		MPW.MP_RulesWindow_DCAoEDamagePressed = MP_RulesWindow.DCAoEDamagePressed
		function MP_RulesWindow.DCAoEDamagePressed() return; end
		
		MPW.MP_RulesWindow_LogicAoEDamagePressed = MP_RulesWindow.LogicAoEDamagePressed
		function MP_RulesWindow.LogicAoEDamagePressed() return; end
		
		MPW.MP_Bug_OnReloadPressed = MP_Bug.OnReloadPressed
		function MP_Bug.OnReloadPressed() return; end
		
		MPW.MP_Bug_OnLeaderTakesItAllPressed = MP_Bug.OnLeaderTakesItAllPressed
		function MP_Bug.OnLeaderTakesItAllPressed() return; end
		
		MPW.MP_RulesWindow_L2RifleFixPressed = MP_RulesWindow.L2RifleFixPressed
		function MP_RulesWindow.L2RifleFixPressed() return; end
		
		-- hack some update funcs to prevent confusion
		MPW.MP_Bug_UpdateReloadButton = MP_Bug.UpdateReloadButton
		function MP_Bug.UpdateReloadButton()
			XGUIEng.HighLightButton( XGUIEng.GetCurrentWidgetID(), 1 )
		end
		
		MPW.MP_Bug_UpdateLeaderTakesItAllButton = MP_Bug.UpdateLeaderTakesItAllButton
		function MP_Bug.UpdateLeaderTakesItAllButton()
			XGUIEng.DisableButton( XGUIEng.GetCurrentWidgetID(), 1 )
		end
		
		MPW.MP_RulesWindow_Update = MP_RulesWindow.Update
		MP_RulesWindow.Update = function()
			MPW.MP_RulesWindow_Update()
			
			XGUIEng.HighLightButton( "MPM20_L2RifleFix", 1 )
			
			XGUIEng.DisableButton( "MPM20_SW", 1 )
			XGUIEng.DisableButton( "MPM20_SWFixedSpawn", 1 )
		end
	end
	--------------------------------------------------------------------------------
	function MPW.Deactivate()
		
		MPW.Log("MPW: Deactivate")
		MPW.IsActive = nil
		
		-- get serverdata
		local d = CustomStringHelper.FromString( XNetwork.EXTENDED_GameInformation_GetCustomString() )

		CustomStringHelper.SetKey( d, "L2RifleFix" )
		CustomStringHelper.SetKey( d, "RELOAD_FIX" )
		
		-- send serverupdate
		XNetwork.EXTENDED_GameInformation_SetCustomString( CustomStringHelper.ToString( d ) )

		MP_RulesWindow.DCAoEDamagePressed = MPW.MP_RulesWindow_DCAoEDamagePressed	
		MP_RulesWindow.LogicAoEDamagePressed = MPW.MP_RulesWindow_LogicAoEDamagePressed
		MP_Bug.OnReloadPressed = MPW.MP_Bug_OnReloadPressed
		MP_Bug.OnLeaderTakesItAllPressed = MPW.MP_Bug_OnLeaderTakesItAllPressed
		MP_RulesWindow.L2RifleFixPressed = MPW.MP_RulesWindow_L2RifleFixPressed
		MP_Bug.UpdateReloadButton = MPW.MP_Bug_UpdateReloadButton
		MP_Bug.UpdateLeaderTakesItAllButton = MPW.MP_Bug_UpdateLeaderTakesItAllButton
		MP_RulesWindow.Update = MPW.MP_RulesWindow_Update

		XGUIEng.HighLightButton( "MPM20_L2RifleFix", 0 )
			
		XGUIEng.DisableButton( "MPM20_SW", 0 )
		XGUIEng.DisableButton( "MPM20_SWFixedSpawn", 0 )
	end
	--------------------------------------------------------------------------------
	local Callbacks = {
		
		OnInitialize = OnInitialize,
		OnGUILoaded = OnGUILoaded,
		OnRuleChanged = OnRuleChanged,
		OnMapStart = OnMapStart,
		
		-- Metadata
		Name = "MPW",
	}
	--------------------------------------------------------------------------------
	ModLoader_Register( Callbacks )
end