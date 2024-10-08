local has_any_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

require "lsp_signature".setup()
vim.o.completeopt = 'menuone,noselect'

local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local cmp = require'cmp'
local luasnip = require("luasnip")

local lspkind = require('lspkind')

local source_mapping = {
  luasnip = "🌜 LuaSnip",
  nvim_lsp = "👐 LSP",
  buffer = "◉ Buffer",
  path = "🚧 Path",
  nvim_lua = "🌙 Lua",
  cmp_tabnine = "💡 Tabnine"
}

cmp.setup({
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lua' },
    { name = 'cmp_tabnine' }
  },

  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      local menu = source_mapping[entry.source.name]
      if entry.source.name == 'cmp_tabnine' then
        if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
          menu = entry.completion_item.data.detail .. ' ' .. menu
        end
        vim_item.kind = ''
      end
      vim_item.menu = menu
      return vim_item
    end
  },

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {

    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),

    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
})

require("luasnip/loaders/from_vscode").load()

if extension == "cpp" or extension == "hpp" or extension == "cc" then
  --print("Olá, amigo, eu estou aqui!")
  require'lspconfig'.clangd.setup{
    filetypes = { "cpp", "hpp", "h" },
    dirname = {"/home/rzj/.config/clangd"},
    cmd = {
      "clangd", "--background-index", "--pch-storage=memory",
      "--clang-tidy", "--suggest-missing-includes",
      "--compile-commands-dir=/home/rzj/.config/clangd"
    },
    init_option = {
      fallbackFlags = {
        {"std=c++17"}
      }
    },
  }
end

if extension == "c" or extension == "h" then
  require'lspconfig'.clangd.setup{
    filetypes = { "c", "h" },
    dirname = {"/home/rzj/.config/Clangd"},
    cmd = {
      "clangd", "--background-index", "--pch-storage=memory",
      "--clang-tidy", "--suggest-missing-includes",
      "--compile-commands-dir=/home/rzj/.config/Clangd"
    },
  }
end



