-- Zigbee Tuya Switch
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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local ep_offset = 0x00

local remapSwitchTbl = {
  ["one"] = "switch1",
  ["two"] = "switch2",
  ["three"] = "switch3",
  ["all"] = "all",
}

local function get_remap_switch(device)
  log.info("<<---- Moon ---->> remapSwitch")
  local remapSwitch = remapSwitchTbl[device.preferences.remapSwitch]

  if remapSwitch == nil then
    return "switch1"
  else
    return remapSwitch
  end
end

local on_off_handler = function(driver, device, command)
  log.info("<<---- Moon ---->> on_off_handler - command.component : ", command.component)
  log.info("<<---- Moon ---->> on_off_handler - command.command : ", command.command)
  local ev = (command.command == "off") and capabilities.switch.switch.off() or capabilities.switch.switch.on()
  local on_off = (command.command == "off") and zcl_clusters.OnOff.server.commands.Off(device) or zcl_clusters.OnOff.server.commands.On(device)

  if command.component == "main" and get_remap_switch(device) == "all" then
    for key, value in pairs(device.profile.components) do
      log.info("<<---- Moon ---->> on_off_handler - key : ", key)
      device.profile.components[key]:emit_event(ev)
      if key ~= "main" then
        device:send_to_component(key, on_off)
      end
    end
  else
    if command.component == "main" or command.component == get_remap_switch(device) then
      device.profile.components["main"]:emit_event(ev)
      command.component = get_remap_switch(device)
    end

    -- Note : The logic is the same, but it uses endpoint.
    --local endpoint = device:get_endpoint_for_component_id(command.component)
    --device:emit_event_for_endpoint(endpoint, capabilities.switch.switch.off())
    --device:send(zcl_clusters.OnOff.server.commands.Off(device):to_endpoint(endpoint))
    device.profile.components[command.component]:emit_event(ev)
    device:send_to_component(command.component, on_off)
  end

end

local received_handler = function(driver, device, OnOff, zb_rx)
  local ep = zb_rx.address_header.src_endpoint.value
  ep = ep - ep_offset
  local component_id = string.format("switch%d", ep)
  log.info("<<---- Moon ---->> received_handler : ", component_id)

  local clickType = OnOff.value
  local ev = capabilities.switch.switch.off()
  if clickType == true then
    ev = capabilities.switch.switch.on()
  end

  ev.state_change = true
  if component_id == get_remap_switch(device) then
    device.profile.components["main"]:emit_event(ev)
  end
  device.profile.components[component_id]:emit_event(ev)

  syncMainComponent(device)
end

local component_to_endpoint = function(device, component_id)
  log.info("<<---- Moon ---->> component_to_endpoint - component_id : ", component_id)
  local ep = component_id:match("switch(%d)")
  log.info("<<---- Moon ---->> component_to_endpoint - converted ep : ", ep)
  log.info("<<---- Moon ---->> component_to_endpoint - converted ep_offset : ", ep_offset)
  ep = ep + ep_offset
  log.info("<<---- Moon ---->> component_to_endpoint - converted ep + ep_offset : ", ep)
  log.info("<<---- Moon ---->> component_to_endpoint - converted tonumber(ep) : ", tonumber(ep))
  return ep and tonumber(ep) or device.fingerprinted_endpoint_id
end

-- It will not be called due to received_handler in zigbee_handlers
local endpoint_to_component = function(device, ep)
  log.info("<<---- Moon ---->> endpoint_to_component - endpoint : ", ep)
  return string.format("switch%d", ep)
end

function syncMainComponent(device)
  local component_id = get_remap_switch(device)
  local remapButtonStatus = device:get_latest_state(component_id, "switch", "switch", "off", nil)
  local ev = capabilities.switch.switch.on()

  if component_id == "all" then
    for key, value in pairs(device.profile.components) do
      local componentStatus = device:get_latest_state(key, "switch", "switch", "off", nil)
      if key ~= "main" and componentStatus == "off" then
        ev = capabilities.switch.switch.off()
        break
      end
    end
  else
    if remapButtonStatus == "off" then
      ev = capabilities.switch.switch.off()
    end
  end
  device.profile.components["main"]:emit_event(ev)
end

local device_info_changed = function(driver, device, event, args)
  syncMainComponent(device)
end

local device_driver_switched = function(driver, device, event, args)
  syncMainComponent(device)
end

local device_init = function(self, device)
  log.info("<<---- Moon ---->> device_init")
  device:set_component_to_endpoint_fn(component_to_endpoint) -- get_endpoint_for_component_id
  device:set_endpoint_to_component_fn(endpoint_to_component)
end

local device_added = function(driver, device)
  log.info("<<---- Moon ---->> device_added")
  -- Workaround : Should emit or send to enable capabilities UI
  for key, value in pairs(device.profile.components) do
    log.info("<<---- Moon ---->> device_added - key : ", key)
    device.profile.components[key]:emit_event(capabilities.switch.switch.on())
    device:send_to_component(key, zcl_clusters.OnOff.server.commands.On(device))
  end
end

local function configure_device(self, device)
  device:configure()
end

local ZIGBEE_TUYA_SWITCH_FINGERPRINTS = {
  { mfr = "_TZ3000_7hp93xpr", model = "TS0002", ep = 0x01 },
  { mfr = "_TZ3000_c0wbnbbf", model = "TS0003", ep = 0x01 },
  { mfr = "3A Smart Home DE", model = "LXN-2S27LX1.0", ep = 0x0B },
  { mfr = "3A Smart Home DE", model = "LXN-3S27LX1.0", ep = 0x0B },
}

local is_multi_switch = function(opts, driver, device)
  for _, fingerprint in ipairs(ZIGBEE_TUYA_SWITCH_FINGERPRINTS) do
    log.info("<<---- Moon ---->> aaaaa1 :", device:get_manufacturer())
    log.info("<<---- Moon ---->> aaaaa2 :", fingerprint.mfr)
    log.info("<<---- Moon ---->> aaaaa3 :", device:get_model())
    log.info("<<---- Moon ---->> aaaaa4 :", fingerprint.model)

    if device:get_manufacturer() == fingerprint.mfr and device:get_model() == fingerprint.model then
      log.info("<<---- Moon ---->> is_multi_switch : true")
      log.info("<<---- Moon ---->> is_multi_switch ep :", fingerprint.ep)
      ep_offset = fingerprint.ep - 1
      return true
    end
  end

  log.info("<<---- Moon ---->> is_multi_switch : false")
  return false
end

local refresh_handler = function(driver, device, command)
  log.info("<<---- Moon ---->> refresh_handler")
end

local multi_switch = {
  NAME = "mutil switch",
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = on_off_handler,
      [capabilities.switch.commands.off.NAME] = on_off_handler,
    },
    --[capabilities.refresh.ID] = {
    --  [capabilities.refresh.commands.refresh.NAME] = refresh_handler,
    --}
  },
  zigbee_handlers = {
    attr = {
      [zcl_clusters.OnOff.ID] = {
        [zcl_clusters.OnOff.attributes.OnOff.ID] = received_handler
      }
    }
  },
  lifecycle_handlers = {
    init = device_init,
    added = device_added,
    driverSwitched = device_driver_switched,
    infoChanged = device_info_changed,
    doConfigure = configure_device
  },
  can_handle = is_multi_switch,
}

return multi_switch