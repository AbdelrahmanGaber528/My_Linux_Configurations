-- ~/.config/nvim/lua/plugins/lsp/lspconfig.lua

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- optional, for autocompletion
  },
  config = function()
    -- Capabilities (with cmp)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Keymaps when LSP attaches
    local on_attach = function(_, bufnr)
      local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
      bufmap("n", "K", vim.lsp.buf.hover, "Hover docs")
      bufmap("n", "gr", vim.lsp.buf.references, "References")
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
      bufmap("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
    end

    -- Setup servers using new API
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config("clangd", {
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { "clangd", "--std=c11" },
    })

    -- Enable them
    vim.lsp.enable("pyright")
    vim.lsp.enable("clangd")

    -- Diagnostics config
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}

