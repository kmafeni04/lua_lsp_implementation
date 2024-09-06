---@meta

---@class Diagnostic
---@field range Range
---@field severity integer
---@field source string
---@field message string

---@class DiagnosticResponseParams
---@field uri string
---@field diagnostics Diagnostic[]

---@class DiagnosticResponse : BaseResponse
---@field params DiagnosticResponseParams
