comms = comms or {}

comms.config = {}

--[[-------------------------------------------------------------------------
@GENERAL SECTION
---------------------------------------------------------------------------]]

comms.config.toggleButton = KEY_P -- defines a button to open commentary menu

comms.config.fontName = 'Arial' -- name of the font to be used to draw text ***REQUIRES RESTART***

comms.config.drawDistance = 1000^2 -- draw distance for commentary ui (don't remove ^2, just change the number)

comms.config.sizeMultiplier = 1 -- scales the size of commentary ui to the defined value

comms.config.commentaryDuration = 14 -- duration for commentary in days

comms.config.allowCustomizeDuration = true -- allow players to customize their commentaries duration?

comms.config.enableLikes = true -- allow players to like comments?

comms.config.likeButton = KEY_N -- defines a button to like comments

comms.config.likeHUDOffset = 0 -- y-offset of like text hud

comms.config.lang = 'en' -- language code to translate all text to your language (you must create the language file first) ***REQUIRES RESTART***

--[[-------------------------------------------------------------------------
@PLAYER SECTION
---------------------------------------------------------------------------]]

comms.config.bypassGroup = {} -- which groups are allowed to create commentaries (leave it empty if you want to make it free for everyone)

comms.config.takeMoney = false -- should players pay for creating commentaries?

comms.config.takeMoneyAmount = 0 -- cost for creating commentary

comms.config.adminGroups = {} -- which groups are allowed to remove and teleport to other commentaries (only groups with admin rights by default)