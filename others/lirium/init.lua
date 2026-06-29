local IrisPath = ...

local utils = require(IrisPath .. ".Utils")
local crypt = require(IrisPath .. ".Crypt")

local Iris = {}
Iris.__index = Iris

function Iris.new(name)
    -- create dir if not exist --
    local slotDirectory = love.filesystem.getInfo("slots")
    if not slotDirectory then
        love.filesystem.createDirectory("slots")
    end
    local self = setmetatable({}, Iris) -- new class --
    self.save = {}
    self.name = name or love.filesystem.getIdentity():gsub("[%s%-%/]", "_")
    -- interface --
    self.allowBackup = true
    self.isDebugMode = false
    return self
end

function Iris:initialize()
    -- check if slot exist, if exist load it, else create then load --
    local hashStr = love._version_major == 12 and love.data.hash("string", "sha1", self.name) or love.data.hash("sha1", self.name)
    local slotHashedName = love.data.encode("string", "hex", hashStr)
    local slotFile = love.filesystem.getInfo("slots/" .. slotHashedName .. ".neu")
    if slotFile then
        -- load save process --
        local slotData = love.filesystem.read("slots/" .. slotHashedName .. ".neu")
        local decryptedSlotData = crypt(slotData, slotHashedName)
        local sucess, data = pcall((load or loadstring)("return" .. decryptedSlotData))
        if not sucess then
            local slotBackupFile = love.filesystem.getInfo("slots/" .. slotHashedName .. ".backup.neu")
            if slotBackupFile then
                -- replace the old file --
                local backupData = love.filesystem.read("slots/" .. slotHashedName .. ".backup.neu")
                love.filesystem.remove("slots/" .. slotHashedName .. ".neu")
                love.filesystem.remove("slots/" .. slotHashedName .. ".backup.neu")

                if self.allowBackup then
                    local backupFileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".backup.neu", "w")
                    -- serialize data --
                    local data = utils.serialize(self.save)
                    local encryptedData = crypt(data, slotHashedName)
                    backupFileSlot:write(encryptedData)
                    backupFileSlot:close()
                end

                local fileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".neu", "w")
                -- serialize data --
                fileSlot:write(backupData)
                fileSlot:close()
            else
                if self.allowBackup then
                    local backupFileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".backup.neu", "w")
                    -- serialize data --
                    local data = utils.serialize(self.save)
                    local encryptedData = crypt(data, slotHashedName)
                    backupFileSlot:write(encryptedData)
                    backupFileSlot:close()
                end

                local data = utils.serialize(self.save)
                local encryptedData = crypt(data, slotHashedName)
                love.filesystem.write("slots/" .. slotHashedName .. ".neu", encryptedData)
            end

            local slotData = love.filesystem.read("slots/" .. slotHashedName .. ".neu")
            local decryptedSlotData = crypt(slotData, slotHashedName)
            local sucess, data = pcall((load or loadstring)("return" .. decryptedSlotData))

            self.save = utils.deepmerge(self.save, data)
        end

        self.save = utils.deepmerge(self.save, data)
    else
        if self.allowBackup then
            local backupFileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".backup.neu", "w")
            -- serialize data --
            local data = utils.serialize(self.save)
            local encryptedData = crypt(data, slotHashedName)
            backupFileSlot:write(encryptedData)
            backupFileSlot:close()
        end
        local fileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".neu", "w")
        -- serialize data --
        local data = utils.serialize(self.save)
        local encryptedData = crypt(data, slotHashedName)
        fileSlot:write(encryptedData)
        fileSlot:close()
    end
end

function Iris:saveSlot()
    -- check if slot exist, if exist load it, else create then load --
    local hashStr = love._version_major == 12 and love.data.hash("string", "sha1", self.name) or love.data.hash("sha1", self.name)
    local slotHashedName = love.data.encode("string", "hex", hashStr)
    local slotFile = love.filesystem.getInfo("slots/" .. slotHashedName .. ".neu")
    if slotFile then
        if self.allowBackup then
            local data = utils.serialize(self.save)
            local encryptedData = crypt(data, slotHashedName)
            love.filesystem.write("slots/" .. slotHashedName .. ".neu", encryptedData)
        end
        local data = utils.serialize(self.save)
        local encryptedData = crypt(data, slotHashedName)
        love.filesystem.write("slots/" .. slotHashedName .. ".backup.neu", encryptedData)
    else
        local fileSlot = love.filesystem.newFile("slots/" .. slotHashedName .. ".neu", "w")
        -- serialize data --
        local data = utils.serialize(self.save)
        local encryptedData = crypt(data, slotHashedName)
        fileSlot:write(encryptedData)
        fileSlot:close()
    end
end

function Iris:removeSlot()
    local hashStr = love._version_major == 12 and love.data.hash("string", "sha1", self.name) or love.data.hash("sha1", self.name)
    local slotHashedName = love.data.encode("string", "hex", hashStr)
    local slotFile = love.filesystem.getInfo("slots/" .. slotHashedName .. ".neu")
    if slotFile then
        love.filesystem.remove("slots/" .. slotHashedName .. ".neu")
        love.filesystem.remove("slots/" .. slotHashedName .. "backup.neu")
    end
end

return Iris