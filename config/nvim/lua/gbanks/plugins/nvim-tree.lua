return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local nvimtree = require("nvim-tree")

        -- recommeded settings from the nvim-tree docs
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- configure nvimtree
        nvimtree.setup({
            view = {
                width = 35,
            },
            renderer = {
                icons = {
		    show = {
			folder = false,
		    },
                    glyphs = {
                        folder = {
                          arrow_closed = "▶", -- arrow when folder is closed
                          arrow_open = "▼", -- arrow when folder is open
                        },
                    },
                },
		group_empty = true,
            },
            -- disable window picker for explorer to work
            -- well with window splits
            actions = {
                open_file = {
                    window_picker = {
                        enable = false,
                    },
                },
            },
            filters = {
                custom = { ".DS_Store", ".*\\.bak[0-9]*$", "^\\.classpath$", "^\\.project$" },
            },
            git = {
                ignore = false,
            }
        })

        -- set keymaps
        vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
        vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
        vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
        vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
    end
}
