# Lua LSP Implementation

This is a basic implementation of an LSP server written in lua

## How to run

### Requirements

- lua5.1 or luajit
- luarocks

### Steps

```sh
git clone 
cd lua_lsp_implementation
luarocks install --lua-version=5.1 --only-deps lua_lsp_implementation-dev-1.rockspec
chmod +x lua_lsp
```
Connect your preferred editor to server by pointing it to the file `~/PARENT_DIRECTORIES/lua_lsp_implementation/lua_lsp`
