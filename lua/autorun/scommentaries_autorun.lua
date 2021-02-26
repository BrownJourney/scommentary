comms = comms or {}

if (SERVER) then

	include('scommentaries/config/sh_config.lua')
	AddCSLuaFile('scommentaries/config/sh_config.lua')

	include('scommentaries/core/sh_core.lua')
	AddCSLuaFile('scommentaries/core/sh_core.lua')

	include("scommentaries/config/languages/".. comms.config.lang .. '.lua')
	AddCSLuaFile("scommentaries/config/languages/".. comms.config.lang .. '.lua')

	include('scommentaries/core/sv_core.lua')
	AddCSLuaFile('scommentaries/core/cl_core.lua')

	AddCSLuaFile('scommentaries/core/cl_options.lua')

	resource.AddWorkshop('2401989259')

end

if (CLIENT) then

	include('scommentaries/config/sh_config.lua')

	include('scommentaries/core/sh_core.lua')

	include("scommentaries/config/languages/".. comms.config.lang .. '.lua')

	include('scommentaries/core/cl_core.lua')

	include('scommentaries/core/cl_options.lua')

end