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
                width = 50,
            },
            renderer = {
                icons = {
		    show = {
			folder = false,
		    },
                    glyphs = {
                        folder = {
                          -- larger arrows
--                          arrow_closed = "\u{25B6}", -- Unicode BLACK RIGHT-POINTING TRIANGLE
--                          arrow_open = "\u{25BC}", -- Unicode BLACK DOWN-POINTING TRIANGLE
                          -- smaller arrows
                          arrow_closed = "\u{25B8}", -- Unicode BLACK RIGHT-POINTING SMALL TRIANGLE
                          arrow_open = "\u{25BE}", -- Unicode BLACK DOWN-POINTING SMALL TRIANGLE
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
