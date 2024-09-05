local interp = require("lib.interp")
local rpc = require("src.rpc")

local log_file = io.open("test.log", "w")
local date = os.date("%Y/%m/%d", os.time())
local time = os.date("%X", os.time())
local logged_file = debug.getinfo(1).source
local line = debug.getinfo(1).currentline
assert(log_file):write(interp("[lua_lsp]{{date}} {{time}} {{logged_file}}:{{line}}: Started\n"))
assert(log_file):close()

local function log(input)
  local log_file = io.open("test.log", "a")
  local date = os.date("%Y/%m/%d", os.time())
  local time = os.date("%X", os.time())
  local logged_file = debug.getinfo(2).source
  local line = debug.getinfo(2).currentline
  assert(log_file):write(interp("[lua_lsp]{{date}} {{time}} {{logged_file}}:{{line}}: {{input}}\n"))
  assert(log_file):close()
end

---@param writer iolib
---@param response string
local response_writer = function(writer, response)
  writer.write(response)
  writer.flush()
  log("Sent the response")
end

-- stdin = io.read("*a")
-- nonblock.nonblock(0)
local function read_in()
  return io.read(1)
  -- return io.read("*l")
end

local stdin = ""
local documents = {}
while true do
  -- if not read_in() then
  --   break
  -- end
  stdin = stdin .. read_in()

  local request, content_length = rpc.decode_message(stdin)
  if request then
    local content_method = request.method
    log(interp("Received message with method: {{content_method}}"))
    if content_method == "initialize" then
      local request_params_clientInfo_name = request.params.clientInfo.name
      local request_params_clientInfo_version = request.params.clientInfo.version
      log(interp("Connected to: {{request_params_clientInfo_name }} {{request_params_clientInfo_version}}"))
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

      ---@class InitializeResponse
      ---@field jsonrpc string
      ---@field id integer
      ---@field result InitializeResult

      ---@type InitializeResponse
      local msg = {
        jsonrpc = "2.0",
        id = request.id,
        result = {
          capabilities = {
            textDocumentSync = 1,
            hoverProvider = true,
            definitionProvider = true,
            codeActionProvider = true,
            completionProvider = {},
          },
          serverInfo = {
            name = "lua_lsp",
            version = "0.0.1-beta",
          },
        },
      }

      local response = rpc.encode_message(msg)
      response_writer(io, response)
    end
    if content_method == "textDocument/didOpen" then
      local request_params_textDocument_uri = request.params.textDocument.uri
      log(interp("Opened {{request_params_textDocument_uri}}"))
      documents[request_params_textDocument_uri] = request.params.textDocument.text
      local diagnostics = {}
      local text = documents[request.params.textDocument.uri]
      local rows = {}
      for text_line in string.gmatch(text, "[^\n]+") do
        table.insert(rows, text_line)
      end
      for row_index, row_line in ipairs(rows) do
        local character_index = string.find(row_line, "VS code")
        if character_index then
          ---@type Diagnostic
          local diagnostic = {
            range = {
              start = {
                line = row_index - 1,
                character = character_index - 1,
              },
              ["end"] = {
                line = row_index - 1,
                character = row_index + #"VS code" - 1,
              },
            },
            severity = 1,
            source = "lol",
            message = "Messing around",
          }
          table.insert(diagnostics, diagnostic)
        end
      end
      local msg = {
        jsonrpc = "2.0",
        method = "textDocument/publishDiagnostics",
        params = {
          uri = request.params.textDocument.uri,
          diagnostics = diagnostics,
        },
      }
      local response = rpc.encode_message(msg)
      log(response)
      response_writer(io, response)
    end
    if content_method == "textDocument/didChange" then
      local request_params_textDocument_uri = request.params.textDocument.uri
      local request_params_contentChanges = request.params.contentChanges
      log(interp("Changed {{request_params_textDocument_uri}}"))
      for _, change in pairs(request_params_contentChanges) do
        documents[request_params_textDocument_uri] = change.text
        ---@class Notification
        ---@field jsonrpc string
        ---@field method string

        ---@class Diagnostic
        ---@field range Range
        ---@field severity integer
        ---@field source string
        ---@field message string

        local diagnostics = {}
        local text = documents[request.params.textDocument.uri]
        local rows = {}
        for text_line in string.gmatch(text, "[^\n]+") do
          table.insert(rows, text_line)
        end
        for row_index, row_line in ipairs(rows) do
          local character_index = string.find(row_line, "VS code")
          if character_index then
            ---@type Diagnostic
            local diagnostic = {
              range = {
                start = {
                  line = row_index - 1,
                  character = character_index - 1,
                },
                ["end"] = {
                  line = row_index - 1,
                  character = row_index + #"VS code" - 1,
                },
              },
              severity = 1,
              source = "lol",
              message = "Messing around",
            }
            table.insert(diagnostics, diagnostic)
          end
          local character_index = string.find(row_line, "Helix")
          if character_index then
            ---@type Diagnostic
            local diagnostic = {
              range = {
                start = {
                  line = row_index - 1,
                  character = character_index - 1,
                },
                ["end"] = {
                  line = row_index - 1,
                  character = row_index + #"VS code" - 1,
                },
              },
              severity = 4,
              source = "Me",
              message = "Helix is ok",
            }
            table.insert(diagnostics, diagnostic)
          end
        end
        local msg = {
          jsonrpc = "2.0",
          id = request.id,
          method = "textDocument/publishDiagnostics",
          params = {
            uri = request.params.textDocument.uri,
            diagnostics = diagnostics,
          },
        }
        local response = rpc.encode_message(msg)
        log(response)
        response_writer(io, response)
      end
    end
    if content_method == "textDocument/hover" then
      local document = request.params.textDocument.uri
      local document_length = #documents[document]

      ---@class HoverResult
      ---@field contents string | table

      ---@class HoverResponse
      ---@field jsonrpc string
      ---@field id integer
      ---@field result HoverResult

      ---@type HoverResponse
      local msg = {
        jsonrpc = "2.0",
        id = request.id,
        result = {
          contents = interp("Characters: {{document_length}}"),
        },
      }
      local response = rpc.encode_message(msg)
      response_writer(io, response)
    end
    if content_method == "textDocument/definition" then
      ---@class Range
      ---@field start Position
      ---@field ["end"] Position

      ---@class DefinitionLocation
      ---@field uri string
      ---@field range Range

      ---@class DefinitionResponse
      ---@field jsonrpc string
      ---@field id integer
      ---@field result DefinitionLocation
      local msg = {
        jsonrpc = "2.0",
        id = request.id,
        result = {
          uri = request.params.textDocument.uri,
          range = {
            start = {
              line = request.params.position.line - 1,
              character = 0,
            },
            ["end"] = {
              line = request.params.position.line - 1,
              character = 0,
            },
          },
        },
      }
      local response = rpc.encode_message(msg)
      log(response)
      response_writer(io, response)
    end
    if content_method == "textDocument/codeAction" then
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

      ---@class CodeActionResponse
      ---@field jsonrpc string
      ---@field id integer
      ---@field result CodeActionResult

      local text = documents[request.params.textDocument.uri]
      local actions = {}
      local rows = {}
      for text_line in string.gmatch(text, "[^\n]+") do
        table.insert(rows, text_line)
      end
      for row_index, row_line in ipairs(rows) do
        local character_index = string.find(row_line, "VS code")
        if character_index then
          local replace_change = {}
          ---@type table<string,TextEdit>
          replace_change[request.params.textDocument.uri] = {
            {
              range = {
                start = {
                  -- LSP counts from zero
                  line = row_index - 1,
                  character = character_index - 1,
                },
                ["end"] = {
                  line = row_index - 1,
                  character = character_index + #"VS code" - 1,
                },
              },
              newText = "Helix",
            },
          }
          table.insert(actions, {
            title = "Replace VS code with a better editor",
            edit = { changes = replace_change },
          })
          local censor_change = {}
          ---@type table<string,TextEdit>
          censor_change[request.params.textDocument.uri] = {
            {
              range = {
                start = {
                  -- LSP counts from zero
                  line = row_index - 1,
                  character = character_index - 1,
                },
                ["end"] = {
                  line = row_index - 1,
                  character = character_index + #"VS code" - 1,
                },
              },
              newText = "VS c*de",
            },
          }
          table.insert(actions, {
            title = "censor VS code",
            edit = { changes = censor_change },
          })
        end
      end
      ---@type CodeActionResponse
      local msg = {
        jsonrpc = "2.0",
        id = request.id,
        result = actions,
      }
      local response = rpc.encode_message(msg)
      response_writer(io, response)
    end
    if content_method == "textDocument/completion" then
      ---@class CompletionItem
      ---@field label string
      ---@field detail string
      ---@field documentation string

      ---@class CompletionResponse
      ---@field jsonrpc string
      ---@field id integer
      ---@field result CompletionItem[]

      ---@type CompletionItem[]
      local items = {
        {
          label = "Sent from LSP",
          detail = "Info from LSP",
          documentation = "Information from the LSP",
        },
      }

      ---@type CompletionResponse
      local msg = {
        jsonrpc = "2.0",
        id = request.id,
        result = items,
      }
      local response = rpc.encode_message(msg)
      response_writer(io, response)
    end
    if content_method == "shutdown" then
      os.exit()
    end
    stdin = ""
  end
end
