local interp = require("lib.interp")
local switch = require("lib.switch")
local rpc = require("src.rpc")

local log_file = io.open("lsp.log", "w")
local date = os.date("%Y/%m/%d", os.time())
local time = os.date("%X", os.time())
local logged_file = debug.getinfo(1).source
local line = debug.getinfo(1).currentline
assert(log_file):write(interp("[lua_lsp]{{date}} {{time}} {{logged_file}}:{{line}}: Started\n"))
assert(log_file):close()

local function log(input)
  local log_file = io.open("lsp.log", "a")
  local date = os.date("%Y/%m/%d", os.time())
  local time = os.date("%X", os.time())
  local logged_file = debug.getinfo(2).source
  local line = debug.getinfo(2).currentline
  assert(log_file):write(interp("[lua_lsp]{{date}} {{time}} {{logged_file}}:{{line}}: {{input}}\n"))
  assert(log_file):close()
end

---@param writer iolib
---@param msg table
local response_writer = function(writer, msg)
  local response = rpc.encode_message(msg)
  writer.write(response)
  writer.flush()
  log("Sent the response")
end

local function read_in()
  return io.read(1)
end

local stdin = ""
local documents = {}
while true do
  stdin = stdin .. read_in()

  local request, content_length = rpc.decode_message(stdin)
  if request then
    log(interp("Received message with method: {{request.method}}"))
    switch(request.method, {
      ["initialize"] = function()
        local request = request
        log(interp("Connected to: {{request.params.clientInfo.name }} {{request.params.clientInfo.version}}"))

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

        response_writer(io, msg)
      end,
      ["textDocument/didOpen"] = function()
        local request = request
        log(interp("Opened {{request.params.textDocument.uri}}"))
        documents[request.params.textDocument.uri] = request.params.textDocument.text
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
          id = request.id,
          method = "textDocument/publishDiagnostics",
          params = {
            uri = request.params.textDocument.uri,
            diagnostics = diagnostics,
          },
        }
        response_writer(io, msg)
      end,
      ["textDocument/didChange"] = function()
        local request = request
        log(interp("Changed {{request.params.textDocument.uri}}"))
        for _, change in pairs(request.params.contentChanges) do
          documents[request.params.textDocument.uri] = change.text
          ---@type Diagnostic[]
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
          ---@type DiagnosticResponse
          local msg = {
            jsonrpc = "2.0",
            id = request.id,
            method = "textDocument/publishDiagnostics",
            params = {
              uri = request.params.textDocument.uri,
              diagnostics = diagnostics,
            },
          }
          response_writer(io, msg)
        end
      end,
      ["textDocument/hover"] = function()
        local document = request.params.textDocument.uri
        local document_length = #documents[document]

        ---@type HoverResponse
        local msg = {
          jsonrpc = "2.0",
          id = request.id,
          result = {
            contents = interp("Characters: {{document_length}}"),
          },
        }
        local response = rpc.encode_message(msg)
        response_writer(io, msg)
      end,
      ["textDocument/definition"] = function()
        ---@type DefinitionResponse
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
        response_writer(io, msg)
      end,
      ["textDocument/codeAction"] = function()
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
        response_writer(io, msg)
      end,
      ["textDocument/completion"] = function()
        ---@type CompletionItem[]
        local items = {
          {
            label = "Sent from LSP",
            detail = "Info from LSP",
            documentation = "Information from the LSP",
          },
          {
            label = "Also sent from LSP",
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
        response_writer(io, msg)
      end,
      ["shutdown"] = function()
        os.exit()
      end,
    })
    stdin = ""
  end
end
