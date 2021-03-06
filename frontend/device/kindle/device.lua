local Generic = require("device/generic/device")
local DEBUG = require("dbg")

local function yes() return true end
local function no() return false end  -- luacheck: ignore

local Kindle = Generic:new{
    model = "Kindle",
    isKindle = yes,
}

local Kindle2 = Kindle:new{
    model = "Kindle2",
    hasKeyboard = yes,
    hasKeys = yes,
    hasDPad = yes,
}

local KindleDXG = Kindle:new{
    model = "KindleDXG",
    hasKeyboard = yes,
    hasKeys = yes,
    hasDPad = yes,
}

local Kindle3 = Kindle:new{
    model = "Kindle3",
    hasKeyboard = yes,
    hasKeys = yes,
    hasDPad = yes,
}

local Kindle4 = Kindle:new{
    model = "Kindle4",
    hasKeys = yes,
    hasDPad = yes,
}

local KindleTouch = Kindle:new{
    model = "KindleTouch",
    isTouchDevice = yes,
    hasKeys = yes,
    touch_dev = "/dev/input/event3",
}

local KindlePaperWhite = Kindle:new{
    model = "KindlePaperWhite",
    isTouchDevice = yes,
    hasFrontlight = yes,
    display_dpi = 212,
    touch_dev = "/dev/input/event0",
}

local KindlePaperWhite2 = Kindle:new{
    model = "KindlePaperWhite2",
    isTouchDevice = yes,
    hasFrontlight = yes,
    display_dpi = 212,
    touch_dev = "/dev/input/event1",
}

local KindleBasic = Kindle:new{
    model = "KindleBasic",
    isTouchDevice = yes,
    touch_dev = "/dev/input/event1",
}

local KindleVoyage = Kindle:new{
    model = "KindleVoyage",
    isTouchDevice = yes,
    hasFrontlight = yes,
    hasKeys = yes,
    display_dpi = 300,
    touch_dev = "/dev/input/event1",
}

local KindlePaperWhite3 = Kindle:new{
    model = "KindlePaperWhite3",
    isTouchDevice = yes,
    hasFrontlight = yes,
    display_dpi = 300,
    touch_dev = "/dev/input/event1",
}

local KindleOasis = Kindle:new{
    model = "KindleOasis",
    isTouchDevice = yes,
    hasFrontlight = yes,
    display_dpi = 300,
    touch_dev = "/dev/input/event3",
}

-- FIXME: To be confirmed!
local KindleBasic2 = Kindle:new{
    model = "KindleBasic2",
    isTouchDevice = yes,
    touch_dev = "/dev/input/event1",
}

function Kindle2:init()
    self.screen = require("ffi/framebuffer_einkfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        is_charging_file = "/sys/devices/platform/charger/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        event_map = require("device/kindle/event_map_keyboard"),
    }
    self.input.open("/dev/input/event0")
    self.input.open("/dev/input/event1")
    Kindle.init(self)
end

function KindleDXG:init()
    self.screen = require("ffi/framebuffer_einkfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        is_charging_file = "/sys/devices/platform/charger/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        event_map = require("device/kindle/event_map_keyboard"),
    }
    self.keyboard_layout = require("device/kindle/keyboard_layout")
    self.input.open("/dev/input/event0")
    self.input.open("/dev/input/event1")
    Kindle.init(self)
end

function Kindle3:init()
    self.screen = require("ffi/framebuffer_einkfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        batt_capacity_file = "/sys/devices/system/luigi_battery/luigi_battery0/battery_capacity",
        is_charging_file = "/sys/devices/platform/fsl-usb2-udc/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        event_map = require("device/kindle/event_map_keyboard"),
    }
    self.keyboard_layout = require("device/kindle/keyboard_layout")
    self.input.open("/dev/input/event0")
    self.input.open("/dev/input/event1")
    Kindle.init(self)
end

function Kindle4:init()
    self.screen = require("ffi/framebuffer_einkfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        batt_capacity_file = "/sys/devices/system/yoshi_battery/yoshi_battery0/battery_capacity",
        is_charging_file = "/sys/devices/platform/fsl-usb2-udc/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        event_map = require("device/kindle/event_map_kindle4"),
    }
    self.input.open("/dev/input/event0")
    self.input.open("/dev/input/event1")
    Kindle.init(self)
end

-- luacheck: push
-- luacheck: ignore
local ABS_MT_POSITION_X = 53
local ABS_MT_POSITION_Y = 54
-- luacheck: pop
function KindleTouch:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        batt_capacity_file = "/sys/devices/system/yoshi_battery/yoshi_battery0/battery_capacity",
        is_charging_file = "/sys/devices/platform/fsl-usb2-udc/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        -- Kindle Touch has a single button
        event_map = { [102] = "Home" },
    }

    -- Kindle Touch needs event modification for proper coordinates
    self.input:registerEventAdjustHook(self.input.adjustTouchScale, {x=600/4095, y=800/4095})

    -- event0 in KindleTouch is "WM8962 Beep Generator" (useless)
    -- event1 in KindleTouch is "imx-yoshi Headset" (useless)
    self.input.open("/dev/input/event2") -- Home button
    self.input.open("/dev/input/event3") -- touchscreen
    self.input.open("fake_events")
    Kindle.init(self)
end

function KindlePaperWhite:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        fl_intensity_file = "/sys/devices/system/fl_tps6116x/fl_tps6116x0/fl_intensity",
        batt_capacity_file = "/sys/devices/system/yoshi_battery/yoshi_battery0/battery_capacity",
        is_charging_file = "/sys/devices/platform/aplite_charger.0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event0")
    self.input.open("fake_events")
end

function KindlePaperWhite2:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        fl_intensity_file = "/sys/class/backlight/max77696-bl/brightness",
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event1")
    self.input.open("fake_events")
end

function KindleBasic:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event1")
    self.input.open("fake_events")
end

function KindleVoyage:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        fl_intensity_file = "/sys/class/backlight/max77696-bl/brightness",
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }
    self.input = require("device/input"):new{
        device = self,
        event_map = {
            [104] = "LPgBack",
            [109] = "LPgFwd",
        },
    }
    -- touch gestures fall into these cold spots defined by (x, y, r)
    -- will be rewritten to 'none' ges thus being ignored
    -- x, y is the absolute position disregard of screen mode, r is spot radius
    self.cold_spots = {
        {
            x = 1080 + 50, y = 485, r = 80
        },
        {
            x = 1080 + 70, y = 910, r = 120
        },
        {
            x = -50, y = 485, r = 80
        },
        {
            x = -70, y = 910, r = 120
        },
    }

    self.input:registerGestureAdjustHook(function(_, ges)
        if ges then
            local pos = ges.pos
            for _, spot in ipairs(self.cold_spots) do
                if (spot.x - pos.x) * (spot.x - pos.x) +
                   (spot.y - pos.y) * (spot.y - pos.y) < spot.r * spot.r then
                   ges.ges = "none"
                end
            end
        end
    end)

    Kindle.init(self)

    self.input.open("/dev/input/event1")
    self.input.open("/dev/input/event2")
    self.input.open("fake_events")
end

function KindlePaperWhite3:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        fl_intensity_file = "/sys/class/backlight/max77696-bl/brightness",
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event1")
    self.input.open("fake_events")
end

function KindleOasis:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        fl_intensity_file = "/sys/class/backlight/max77696-bl/brightness",
        -- NOTE: Probably points to the embedded battery. The one in the cover is codenamed "soda".
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event3")
    self.input.open("fake_events")
end

-- TODO: Confirm that this is accurate!
function KindleBasic2:init()
    self.screen = require("ffi/framebuffer_mxcfb"):new{device = self, debug = DEBUG}
    self.powerd = require("device/kindle/powerd"):new{
        device = self,
        batt_capacity_file = "/sys/devices/system/wario_battery/wario_battery0/battery_capacity",
        is_charging_file = "/sys/devices/system/wario_charger/wario_charger0/charging",
    }

    Kindle.init(self)

    self.input.open("/dev/input/event1")
    self.input.open("fake_events")
end

--[[
Test if a kindle device has Special Offers
--]]
local function isSpecialOffers()
    -- Look at the current blanket modules to see if the SO screensavers are enabled...
    local lipc = require("liblipclua")
    if not lipc then
        DEBUG("could not load liblibclua")
        return false
    end
    local lipc_handle = lipc.init("com.github.koreader.device")
    if not lipc_handle then
        DEBUG("could not get lipc handle")
        return false
    end
    local so = false
    local loaded_blanket_modules = lipc_handle:get_string_property("com.lab126.blanket", "load")
    if string.find(loaded_blanket_modules, "ad_screensaver") then
        so = true
    end
    lipc_handle:close()
    return so
end

function KindleTouch:exit()
    if isSpecialOffers() then
        -- fake a touch event
        if self.touch_dev then
            local width, height = self.screen:getScreenWidth(), self.screen:getScreenHeight()
            require("ffi/input").fakeTapInput(self.touch_dev,
                math.min(width, height)/2,
                math.max(width, height)-30
            )
        end
    end
    Generic.exit(self)
end
KindlePaperWhite.exit = KindleTouch.exit
KindlePaperWhite2.exit = KindleTouch.exit
KindleBasic.exit = KindleTouch.exit
KindleVoyage.exit = KindleTouch.exit
KindlePaperWhite3.exit = KindleTouch.exit
KindleOasis.exit = KindleTouch.exit
KindleBasic2.exit = KindleTouch.exit

function Kindle3:exit()
    -- send double menu key press events to trigger screen refresh
    os.execute("echo 'send 139' > /proc/keypad;echo 'send 139' > /proc/keypad")

    Generic.exit(self)
end

KindleDXG.exit = Kindle3.exit


----------------- device recognition: -------------------

local function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end


local kindle_sn_fd = io.open("/proc/usid", "r")
if not kindle_sn_fd then return end
local kindle_sn = kindle_sn_fd:read()
kindle_sn_fd:close()
local kindle_devcode = string.sub(kindle_sn,3,4)
local kindle_devcode_v2 = string.sub(kindle_sn,4,6)

-- NOTE: Update me when new devices come out :)
local k2_set = Set { "02", "03" }
local dx_set = Set { "04", "05" }
local dxg_set = Set { "09" }
local k3_set = Set { "08", "06", "0A" }
local k4_set = Set { "0E", "23" }
local touch_set = Set { "0F", "11", "10", "12" }
local pw_set = Set { "24", "1B", "1D", "1F", "1C", "20" }
local pw2_set = Set { "D4", "5A", "D5", "D6", "D7", "D8", "F2", "17",
                  "60", "F4", "F9", "62", "61", "5F" }
local kt2_set = Set { "C6", "DD" }
local kv_set = Set { "13", "54", "2A", "4F", "52", "53" }
local pw3_set = Set { "0G1", "0G2", "0G4", "0G5", "0G6", "0G7",
                  "0KB", "0KC", "0KD", "0KE", "0KF", "0KG" }
local koa_set = Set { "0GC", "0GD", "0GP", "0GQ", "0GR", "0GS" }
local kt3_set = Set { "0DT", "0K9", "0KA" }

if k2_set[kindle_devcode] then
    return Kindle2
elseif dx_set[kindle_devcode] then
    return Kindle2
elseif dxg_set[kindle_devcode] then
    return KindleDXG
elseif k3_set[kindle_devcode] then
    return Kindle3
elseif k4_set[kindle_devcode] then
    return Kindle4
elseif touch_set[kindle_devcode] then
    return KindleTouch
elseif pw_set[kindle_devcode] then
    return KindlePaperWhite
elseif pw2_set[kindle_devcode] then
    return KindlePaperWhite2
elseif kt2_set[kindle_devcode] then
    return KindleBasic
elseif kv_set[kindle_devcode] then
    return KindleVoyage
elseif pw3_set[kindle_devcode_v2] then
    return KindlePaperWhite3
elseif koa_set[kindle_devcode_v2] then
    return KindleOasis
elseif kt3_set[kindle_devcode_v2] then
    return KindleBasic2
end

error("unknown Kindle model "..kindle_devcode)
