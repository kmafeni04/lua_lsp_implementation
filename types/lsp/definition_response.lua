---@meta

---@class Range
---@field start Position
---@field ["end"] Position

---@class DefinitionLocation
---@field uri string
---@field range Range

---@class DefinitionResponse : BaseResponse
---@field result DefinitionLocation
