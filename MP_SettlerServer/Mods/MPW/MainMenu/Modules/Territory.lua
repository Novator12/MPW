--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Territory
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
MPW.Territory = {}
MPW.Modules.Territory = {
	Priority = 90,
	Dependencies = { "Core" },
	Incompatible = {},
	Name = "Territory",
	Description = "Fügt Territorien wie in Die Siedler 4 hinzu. @cr Neben eurer Burg, könnt ihr euer Territorium mit Dorfzentren, Aussichtstürmen und Außenposten erwetern. @cr @cr @color:255,204,51,255 Dieser Spielmodus funktioniert aktuell nur, wenn die Burgen und Aussichtstürme von verschiedenen Spielern zu Spielstart nicht zu dicht stehen. Im laufe des Spiels platzierte Gebäude machen keine Probleme. An einer Lösung wird gearbeitet."
}
--------------------------------------------------------------------------------
function MPW.Territory.OnInitialize()
	LuaDebugger.Log( "Territory.OnInitialize()" )
	return true
end
--------------------------------------------------------------------------------
function MPW.Territory.OnMapStart()
	LuaDebugger.Log( "Territory.OnMapStart()" )
	
	-- this will only be called if the module is active and all dependencies are met
	-- add xmls here, like Enitites, UpgradeCategories ...
	
	CMod.AppendToXML("data\\config\\entities.xml", [[<Entity>XD_Border</Entity>]])
	CMod.AppendToXML(
		"data\\config\\models.xml",
		[[<Model id="XD_Border">
		<Effect>SimpleObjectPlayerColor</Effect>
		<OcclusionCaster>True</OcclusionCaster>
		<CastShadow>False</CastShadow>
		</Model>]]
	)
	CMod.AppendToXML("data\\config\\technologies.xml", [[<Technology>UP1_Outpost</Technology>]])
	CMod.AppendToXML("data\\config\\technologies.xml", [[<Technology>UP2_Outpost</Technology>]])
end