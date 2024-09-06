---@meta

---@class RequestClientInfo
---@field name string
---@field version string

---@class TextDocument
---@field uri string
---@field text string

---@class ContentChange
---@field text string

---@class HoverRequest

---@class Position
---@field line integer
---@field character integer

---@class RequestParams
---@field clientInfo RequestClientInfo
---@field textDocument TextDocument
---@field contentChanges ContentChange[]
---@field hoverRequest HoverRequest
---@field position Position

---@class Request
---@field id number
---@field method string
---@field params RequestParams
