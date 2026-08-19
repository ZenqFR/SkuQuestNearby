-- SkuQuestNearby/OnEnable.lua -- final wiring.
local ADDON_NAME, NS = ...
if NS.SkuMissing then return end
local Log, SkuQuestNearby = NS.Log, NS.SkuQuestNearby

function SkuQuestNearby:OnEnable()
	Log("OnEnable start.")

	local tOk, tErr = pcall(NS.InstallMenuEntry)
	if not tOk then Log("InstallMenuEntry THREW: %s", tostring(tErr)) end

	self:RegisterChatCommand("sqn", "SlashCommand")

	print("|cff00ff00SkuQuestNearby|r: " ..
		(Sku.deEn and Sku.deEn(
			"aktiv. Menü: Quêtes -> Objectifs de quêtes proches.",
			"active. Menu: Quêtes -> Objectifs de quêtes proches.",
			"actif. Menu : Quêtes -> Objectifs de quêtes proches.")
		or "actif. Menu : Quêtes -> Objectifs de quêtes proches."))
	Log("OnEnable end.")
end

-- /sqn -- for testing/diagnostics: dumps the list sizes to chat without
-- going through the menu.
function SkuQuestNearby:SlashCommand(aMsg)
	local tCtx = NS.GetPlayerContext()
	if not tCtx then
		print("|cff80c0ffSkuQuestNearby|r: position inconnue.")
		return
	end
	local tObjectives = NS.ScanQuestObjectives(tCtx)
	local tAvailable = NS.ScanAvailableToAccept()
	print(string.format("|cff80c0ffSkuQuestNearby|r: %d objectif(s) de quete, %d a accepter (zone actuelle).",
		#tObjectives, #tAvailable))
end

function SkuQuestNearby:OnDisable()
	Log("OnDisable.")
end
