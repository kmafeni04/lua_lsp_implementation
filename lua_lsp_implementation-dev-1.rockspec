---@diagnostic disable:lowercase-global
package = "lua_lsp_implementation"
version = "dev-1"
source = {
  url = "https://github.com/kmafeni04/lua_lsp_implementation",
}
description = {
  homepage = "https://github.com/kmafeni04/lua_lsp_implementation",
  license = "*** please specify a license ***",
}

dependencies = {
  "lua == 5.1",
  "lua-cjson == 2.1.0.10-1",
  "busted == 2.2.0-1",
}

build = {
  type = "builtin",
  modules = {},
}
