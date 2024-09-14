describe("rpc encode test", function()
  it("checks that content is of the epected format", function()
    local rpc = require("src.rpc")

    local expected = 'Content-Length: 18\r\n\r\n{"method":"world"}'
    local content = rpc.encode_message({ method = "world" })
    assert.are.same(expected, content)
  end)
end)

describe("rpc decode test", function()
  it("checks if a message can be decoded and returns it's (base message, content length)", function()
    local rpc = require("src.rpc")
    local pipe = require("utils.pipe")

    local expected_len = 18
    local expected_message = "world"
    local request, content_len = pipe({ method = "world" }, rpc.encode_message, rpc.decode_message)
    assert.are.same(expected_message, request.method)
    assert.are.same(expected_len, content_len)
  end)
end)
