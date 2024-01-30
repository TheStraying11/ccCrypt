local function requireOrInstall(lib, installer, err)
    local status, result = pcall(require, lib)
    if status then
        return result
    else
        if installer then
            shell.run(installer)
            local status, result = pcall(require, lib)
            if status then
                return result
            else
                print("Failed to install/import "..lib..":")
                error(result)
            end
        else
            error(err)
        end
    end
end

local getChacha = "pastebin get GPzf9JSa chacha.lua"
local chacha = requireOrInstall("chacha", getChacha)

local ccCrypt = {}

ccCrypt.__index = ccCrypt

function ccCrypt:new(key)
    local mt = {
        key = key
    }
    
    setmetatable(mt, ccCrypt)
    
    return mt
end

function ccCrypt:genIV(len)
    local iv = {}
    for i = 1, len do
        iv[#iv+1] = math.random(0, 255)
    end
    return iv
end

function ccCrypt:encrypt(msg)
    local iv = self:genIV(12)
    local ctx = chacha.crypt(msg, self.key, iv)
    return {iv, ctx}
end

function ccCrypt:decrypt(msg)
    local iv, ctx = table.unpack(msg)
    return tostring(chacha.crypt(ctx, self.key, iv))
end

ccCrypt = setmetatable(ccCrypt, {
        __call = ccCrypt.new
    }
)

return ccCrypt
