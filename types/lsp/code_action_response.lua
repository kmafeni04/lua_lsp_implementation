---@meta

---@class TextEdit
---@field range Range
---@field newText string

---@class WorkspaceEdit
---@field changes table<string,TextEdit>

---@class Command
---@field title string
---@field command string
---@field Arguments table

---@class CodeActionResult
---@field title string
---@field edit WorkspaceEdit
---@field command Command

---@class CodeActionResponse : BaseResponse
---@field result CodeActionResult
