local lsp = {}

---@param id integer
---@param msg_fields table
---@param method? string
function lsp.new_message(id, msg_fields, method)
  local msg = {
    jsonrpc = "2.0",
    id = id,
    method = method or nil,
    msg_fields,
  }
  return msg
end

return lsp
