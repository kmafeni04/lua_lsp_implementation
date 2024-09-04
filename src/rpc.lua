local json = require("cjson")
local pipe = require("lib.pipe")
local interp = require("lib.interp")

local rpc = {}

---@param msg table<string,string>
---@return string
rpc.encode_message = function(msg)
  local encoded, content = pcall(json.encode, msg)
  if not encoded then
    error("Message could not be encoded")
  end
  local content_len = #content
  local result = interp("Content-Length: {{content_len}}\r\n\r\n{{content}}")
  return result
end

---@class RequestClientInfo
---@field name string
---@field version string

---@class TextDocument
---@field uri string
---@field text string

---@class ContentChanges
---@field text string

---@class HoverRequest

---@class Position
---@field line integer
---@field character integer

---@class RequestParams
---@field clientInfo RequestClientInfo
---@field textDocument TextDocument
---@field contentChanges ContentChanges[]
---@field hoverRequest HoverRequest
---@field position Position

---@class Request
---@field id number
---@field method string
---@field params RequestParams

---@param msg string
---@return Request? request
---@return integer? content_length
rpc.decode_message = function(msg)
  local header, content = msg:match("(.-)\r\n\r\n(.*)")
  if not header then
    return nil, nil
  end
  if not content then
    return nil, nil
  end

  -- local method_start = string.find(content, '{"method":')
  -- local method = string.sub(content, assert(method_start), #content)
  local decoded, request = pcall(json.decode, content)
  if not decoded then
    return nil, nil
  end
  return request, #content
end

rpc.split = function(msg)
  local header, content = msg:match("(.-)\r\n\r\n(.*)")
  if not header then
    return nil, nil
  end
  if not content then
    return nil, nil
  end
  local totalLength = #header + 4 + #content
  return totalLength, msg:sub(1, totalLength)
end

return rpc
