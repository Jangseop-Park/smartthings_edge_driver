-- Zigbee Tuya Button
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local log = require "log"
local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"
local device_management = require "st.zigbee.device_management"
local zcl_clusters = require "st.zigbee.zcl.clusters"

local comp = { "button1", "button2", "button3", "button4" }

local button_handler = function(driver, device, zb_rx)
    log.info("button_handler : ")
    device:emit_event(capabilities.button.button.pushed())

    --local ev = capabilities.button.button.pushed()
    --ev.state_change = true
    device.profile.components["button1"]:emit_event(capabilities.button.button.pushed())
    device:emit_event(capabilities.button.button.pushed())

    device.profile.components[button2]:emit_event(capabilities.button.button.pushed())
    device:emit_event(capabilities.button.button.pushed())

    device.profile.components[comp[3]]:emit_event(capabilities.button.button.pushed())
    device:emit_event(capabilities.button.button.pushed())

    ----local rx = zb_rx.body.zcl_body.body_bytes
    ----local button = string.byte(rx:sub(1, 1))
    ----local buttonState = string.byte(rx:sub(5, 5))
    --
    --log.info("button_handler rx : " + buttonState)
    --log.info("button_handler button : " + buttonState)
    --log.info("button_handler buttonState : " + buttonState)
    --
    --
    ----local buttonHoldTime = string.byte(rx:sub(7,7))
    --
    ------ 1 is double
    ----if buttonState == 0 then
    ----  local ev = capabilities.button.button.pushed()
    ----  ev.state_change = true
    ----  device.profile.components[comp[button]]:emit_event(ev)
    ----  device:emit_event(ev)
    ----elseif buttonState == 2 then
    ----  local ev = capabilities.button.button.held()
    ----  ev.state_change = true
    ----  device.profile.components[comp[button]]:emit_event(ev)
    ----  device:emit_event(ev)
    ----end
end


local device_added = function(driver, device)
    device:emit_event(capabilities.button.supportedButtonValues({ "pushed", "double", "held" }))
    device:emit_event(capabilities.button.button.pushed())

    for i, v in ipairs(comp) do
        device.profile.components[v]:emit_event(capabilities.button.supportedButtonValues({ "pushed", "double", "held" }))
        device.profile.components[v]:emit_event(capabilities.button.button.pushed())
    end
end

local configure_device = function(self, device)
    device:configure()
    device:send(device_management.build_bind_request(device, 0x0006, device.driver.environment_info.hub_zigbee_eui))
    device:send(zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:read(device))
end

local tuya_button_driver_template = {
    supported_capabilities = {
        capabilities.button,
        capabilities.battery
        --capabilities.refresh
    },
    -- zigbee 로 들어오는 신호 = 리모콘 버튼을 누를때
    zigbee_handlers = {
        cluster = {
            [0x0006] = {
                [0x00] = button_handler, -- pushed
                [0x01] = button_handler, -- doulbe or button1
                [0x02] = button_handler  -- held
            },
        },
    },
    ------ UI로 들어오는 신호 = 화면 터치 할때
    --capability_handlers = {
    --    [capabilities.refresh.ID] = {
    --        [capabilities.refresh.commands.refresh.NAME] = refresh_handler
    --    }
    --},
    lifecycle_handlers = {
        doConfigure = configure_device,
        added = device_added
    }
}

defaults.register_for_default_handlers(tuya_button_driver_template, tuya_button_driver_template.supported_capabilities)
local zigbee_driver = ZigbeeDriver("uya-button", tuya_button_driver_template)
zigbee_driver:run()

-- <ZigbeeDevice: 2db7ce5e-40f1-4363-88e3-f8105e69cf9f [0x9ECE] (Tuya 4 Button)> received Zigbee message: < ZigbeeMessageRx || type: 0x00, < AddressHeader || src_addr: 0x9ECE, src_endpoint: 0x01, dest_addr: 0x0000, dest_endpoint: 0x01, profile: 0x0104, cluster: OnOff >, lqi: 0xFF, rssi: -78, body_length: 0x0004, < ZCLMessageBody || < ZCLHeader || frame_ctrl: 0x01, seqno: 0x76, ZCLCommandId: 0xFD >, GenericBody:  00 > >
-- <ZigbeeDevice: 2db7ce5e-40f1-4363-88e3-f8105e69cf9f [0x9ECE] (Tuya 4 Button)> received Zigbee message: < ZigbeeMessageRx || type: 0x00, < AddressHeader || src_addr: 0x9ECE, src_endpoint: 0x04, dest_addr: 0x0000, dest_endpoint: 0x01, profile: 0x0104, cluster: OnOff >, lqi: 0xFF, rssi: -60, body_length: 0x0004, < ZCLMessageBody || < ZCLHeader || frame_ctrl: 0x01, seqno: 0x78, ZCLCommandId: 0xFD >, GenericBody:  00 > >
-- <ZigbeeDevice: e3642d4f-f9cd-444f-b8a3-db8aca4195a5 [0x7A94] (Tuya 4 Button)> received Zigbee message: < ZigbeeMessageRx || type: 0x00, < AddressHeader || src_addr: 0x7A94, src_endpoint: 0x01, dest_addr: 0x0000, dest_endpoint: 0x01, profile: 0x0104, cluster: OnOff >, lqi: 0xFF, rssi: -42, body_length: 0x0004, < ZCLMessageBody || < ZCLHeader || frame_ctrl: 0x01, seqno: 0x17, ZCLCommandId: 0xFD >, GenericBody:  02 > >



--local function component_to_endpoint(device, component_id)
--    if component_id == "main" then
--        return device.fingerprinted_endpoint_id
--    else
--        local ep_num = component_id:match("switch(%d)")
--        return ep_num and tonumber(ep_num) or device.fingerprinted_endpoint_id
--    end
--end
--
--local function endpoint_to_component(device, ep)
--    if ep == device.fingerprinted_endpoint_id then
--        return "main"
--    else
--        return string.format("switch%d", ep)
--    end
--end