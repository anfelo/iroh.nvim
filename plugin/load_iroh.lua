vim.api.nvim_create_user_command("IrohTransform", function()
	require("iroh").transform()
end, { range = true })
