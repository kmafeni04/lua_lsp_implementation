---@meta

---@class InitializeResultCapabilities
---@field textDocumentSync integer
---@field hoverProvider boolean
---@field definitionProvider boolean
---@field codeActionProvider boolean
---@field completionProvider table<string,any>

---@class InitializeResultServerInfo
---@field name string
---@field version string

---@class InitializeResult
---@field capabilities InitializeResultCapabilities
---@field serverInfo InitializeResultServerInfo

---@class InitializeResponse : BaseResponse
---@field result InitializeResult
