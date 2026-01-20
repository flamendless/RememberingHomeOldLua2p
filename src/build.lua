return {
	{
		name = "Remembering Home",
		config = "dev",
		developer = "flamendless",
		output = "../release",
		version = "0.1.0",
		love = "11.5",
		ignore = {
			"release",
			"scripts",
			"src2p",
			"output_dev",
			"libs",
		},
		icon = "res/icon.png",
		use32bit = false,
		identifier = "org.flamendless.rememberinghome",
		libs = {
			-- windows = { "resources/plugin.dll" },
			-- all = { "resources/license.txt" }
		},
		platforms = { "windows", "macos" }
	},
}
