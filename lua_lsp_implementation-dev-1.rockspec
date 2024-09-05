---@diagnostic disable:lowercase-global
package = "lua_lsp_implementation"
version = "dev-1"
source = {
  url = "",
}
description = {
  homepage = "*** please enter a project homepage ***",
  license = "*** please specify a license ***",
}

dependencies = {
  "lua == 5.1, JIT",
  "lua-cjson == 2.1.0.10-1",
  "busted == 2.2.0-1",
}

build = {
  type = "builtin",
  modules = {},
}
