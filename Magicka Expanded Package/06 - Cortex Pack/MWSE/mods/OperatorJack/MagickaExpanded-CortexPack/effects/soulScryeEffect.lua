local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")

tes3.claimSpellEffectId("soulScrye", 332)

local function addSoulScryeEffect()
	framework.effects.mysticism.createBasicEffect({
		-- Base information.
		id = tes3.effect.soulScrye,
		name = "Soul Scrye",
		description = "While active, lets the caster view the skills and condition of the target.",

		-- Basic dials.
		baseCost = 30.0,

		-- Various flags.
        canCastSelf = true,
        hasNoMagnitude = true,
        hasContinuousVFX = true,

		-- Graphics/sounds.
        lighting = { 0, 0, 0 },

		-- Required callbacks.
		onTick = function(e) e:trigger() end,
	})
end

event.register("magicEffectsResolved", addSoulScryeEffect)

-- Register the GUI IDs for our custom tooltips feature.
local GUI_ID = nil
local function registerUi()
    GUI_ID = {}
    GUI_ID.container = tes3ui.registerID("OJ_ME_SS_Tooltip_Container")
end

local function createSoulScryeUi(reference, tooltip)
    if (GUI_ID == nil) then
        registerUi()
    end

    local container = tooltip:createBlock({id = GUI_ID.container} )    
    container.flowDirection = "top_to_bottom"
    container.childAlignX = 0
    container.autoHeight = true
    container.autoWidth = true

    local divider = container:createDivider()

    local label = container:createLabel({
        text = "Soul Scrye"
    })
    label.color = tes3ui.getPalette("header_color")
    label.wrapText = true

    local conditions = container:createBlock()
    conditions.flowDirection = "top_to_bottom"
    conditions.childAlignX = 0
    conditions.autoHeight = true
    conditions.autoWidth = true

    local health = conditions:createBlock()  
    health.flowDirection = "left_to_right"
    health.childAlignX = 0
    health.autoHeight = true
    health.autoWidth = true

    local bar = health:createFillBar({
        current = reference.mobile.health.current,
        max = reference.mobile.health.base
    })
    bar.widget.fillColor = tes3ui.getPalette("health_color")

    local magicka = conditions:createBlock()  
    magicka.flowDirection = "left_to_right"
    magicka.childAlignX = 0
    magicka.autoHeight = true
    magicka.autoWidth = true
    
    local bar = magicka:createFillBar({
        current = reference.mobile.magicka.current,
        max = reference.mobile.magicka.base
    })
    bar.widget.fillColor = tes3ui.getPalette("magic_color")

    local fatigue = conditions:createBlock()  
    fatigue.flowDirection = "left_to_right"
    fatigue.childAlignX = 0
    fatigue.autoHeight = true
    fatigue.autoWidth = true
    
    local bar = fatigue:createFillBar({
        current = reference.mobile.fatigue.current,
        max = reference.mobile.fatigue.base
    })
    bar.widget.fillColor = tes3ui.getPalette("fatigue_color")

    local linebreak = container:createLabel({text = ""})

    local stats = container:createBlock()
    stats.flowDirection = "top_to_bottom"
    stats.childAlignX = 0
    stats.autoHeight = true
    stats.autoWidth = true

    local level = stats:createBlock()
    level.flowDirection = "left_to_right"
    level.childAlignX = 0
    level.autoHeight = true
    level.autoWidth = true

    local levelDescLabel = level:createLabel({text = "Level"})
    local levelStatLabel = level:createLabel({text = reference.object.level})

    return container
end

local function createSoulScryeForCreature(reference, tooltip)
    local container = createSoulScryeUi(reference, tooltip)
end

local function createSoulScryeForNpc(reference, tooltip)
    local container = createSoulScryeUi(reference, tooltip)
end

local function onTooltipDrawn(e)
    local ref = e.reference
    local isAffectedBySoulScrye = tes3.isAffectedBy({
        reference = tes3.player,
        effect = tes3.effect.soulScrye
    })

    -- Only show if mind scan is active.
    if (isAffectedBySoulScrye) then
        framework.debug("Affected by Soul Scrye.")
        -- and target is valid.
        if (ref) then
            framework.debug("Target is valid.")
            -- and target is not dead.
            if (ref.mobile.isDead == false) then
                -- and target is an NPC or creature.
                if (e.object.objectType == tes3.objectType.npc) then
                    framework.debug("Target is NPC.")
                    createSoulScryeForNpc(ref, e.tooltip)
                elseif (e.object.objectType == tes3.objectType.creature) then
                    framework.debug("Target is creature.")
                    createSoulScryeForCreature(ref, e.tooltip)
                end
            end
        end
    end
end

event.register("uiObjectTooltip", onTooltipDrawn, {priority=200})