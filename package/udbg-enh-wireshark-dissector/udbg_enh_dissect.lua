-- SPDX-License-Identifier: BSD-3-Clause-Clear
-- Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.

-- ================= Constants =================
local DEBUG_MSG_HEADER_SIZE = 24
local UDBG_ENH_UUID_SIZE = 16
local UDBG_ENH_APP_ID_SIZE = 64

local UDBG_ENH_CTRL_CMD_BASE = 0x11110000
local UDBG_ENH_DATA_CMD_BASE = 0x10000000

local UDBG_ENH_CTRL_SUBSCRIBE_REQ = 0x0001
local UDBG_ENH_CTRL_SUBSCRIBE_RESP = 0x0002

local UDBG_ENH_DATA_NL_TX = 0x0001
local UDBG_ENH_DATA_NL_RX = 0x0002
local UDBG_ENH_DATA_LOG = 0x0003
local UDBG_ENH_DATA_NL_RX_NCTRL_NL80211 = 0x0004

local UDBG_SUBSCRIBE_REQ = UDBG_ENH_CTRL_CMD_BASE + UDBG_ENH_CTRL_SUBSCRIBE_REQ
local UDBG_SUBSCRIBE_RESP = UDBG_ENH_CTRL_CMD_BASE + UDBG_ENH_CTRL_SUBSCRIBE_RESP
local UDBG_NL_TX = UDBG_ENH_DATA_CMD_BASE + UDBG_ENH_DATA_NL_TX
local UDBG_NL_RX = UDBG_ENH_DATA_CMD_BASE + UDBG_ENH_DATA_NL_RX
local UDBG_LOG = UDBG_ENH_DATA_CMD_BASE + UDBG_ENH_DATA_LOG
local UDBG_NLCTRL_NL80211 = UDBG_ENH_DATA_CMD_BASE + UDBG_ENH_DATA_NL_RX_NCTRL_NL80211

-- ================= Lower-level dissectors =================
local netlink_dissector = Dissector.get("netlink")
assert(netlink_dissector, "Could not find Wireshark dissector 'netlink'")

-- ================= Proto =================
local udbg_enh = Proto("udbg_enh", "UDBG ENH Protocol")

-- ================= Fields =================
local f_handle               = ProtoField.uint64("udbg_enh.handle", "Handle", base.HEX)
local f_msg_type             = ProtoField.string("udbg_enh.msg_type", "Message Type")
local f_timestamp            = ProtoField.uint64("udbg_enh.timestamp", "Timestamp", base.DEC)
local f_length               = ProtoField.uint32("udbg_enh.length", "Length", base.DEC)
local f_payload_len          = ProtoField.uint32("udbg_enh.payload_len", "Payload Length", base.DEC)
local f_log_text             = ProtoField.string("udbg_enh.log.text", "Log Text")
local f_sub_resp_status      = ProtoField.int32("udbg_enh.subscribe_resp.status", "Subscribe Response Status", base.DEC)

-- SUBSCRIBE_REQ payload
local f_sub_pid    = ProtoField.uint32("udbg_enh.subscribe_req.pid", "PID", base.DEC)
local f_sub_uuid   = ProtoField.bytes("udbg_enh.subscribe_req.uuid", "UUID")
local f_sub_app_id = ProtoField.string("udbg_enh.subscribe_req.app_id", "App ID")


udbg_enh.fields = {
    f_handle,
    f_msg_type,
    f_timestamp,
    f_length,
    f_payload_len,
    f_log_text,
    f_sub_resp_status,
    f_sub_pid,
    f_sub_uuid,
    f_sub_app_id,
}

-- ================= Helpers =================
local function set_col(col, value)
    col:set(value)
end

local function udbg_msg_base(msg_type)
    return msg_type - (msg_type % 0x10000)
end

local function udbg_msg_name(msg_type)
    if msg_type == UDBG_SUBSCRIBE_REQ then
        return "UDBG_SUBSCRIBE_REQ"
    elseif msg_type == UDBG_SUBSCRIBE_RESP then
        return "UDBG_SUBSCRIBE_RESP"
    elseif msg_type == UDBG_NL_TX then
        return "UDBG_NL_TX"
    elseif msg_type == UDBG_NL_RX then
        return "UDBG_NL_RX"
    elseif msg_type == UDBG_NLCTRL_NL80211 then
        return "UDBG_NLCTRL_NL80211"
    elseif msg_type == UDBG_LOG then
        return "UDBG_LOG"
    elseif udbg_msg_base(msg_type) == UDBG_ENH_CTRL_CMD_BASE then
        return "CTRL_UNKNOWN"
    end

    return "UNKNOWN"
end

local function dissect_subscribe_req_payload(tvb, tree, offset, length)
    local sub_req_len = 4 + UDBG_ENH_UUID_SIZE + UDBG_ENH_APP_ID_SIZE

    if length < sub_req_len then
        return
    end

    local sub = tree:add(tvb(offset, sub_req_len), "Subscribe Request")
    sub:add_le(f_sub_pid, tvb(offset, 4))
    sub:add(f_sub_uuid, tvb(offset + 4, UDBG_ENH_UUID_SIZE))
    sub:add(f_sub_app_id, tvb(offset + 4 + UDBG_ENH_UUID_SIZE, UDBG_ENH_APP_ID_SIZE))
end

local function dissect_subscribe_resp_payload(tvb, tree, offset, length)
    if length < 4 then
        return
    end

    local sub = tree:add(tvb(offset, 4), "Subscribe Response")
    sub:add_le(f_sub_resp_status, tvb(offset, 4))
end

-- Build the exact 16-byte cooked/SLL-style header expected by packet-netlink.c.
--
-- packet-netlink.c expects:
--
--   offset  size  value
--   ------  ----  --------------------------------
--   0       2     packet type, ignored here
--   2       2     ARPHRD_NETLINK = 0x0338
--   4       10    unused/spare bytes
--   14      2     Netlink protocol = NETLINK_GENERIC = 0x0010
--
-- Therefore bytes are:
--
--   00 00 03 38 00 00 00 00 00 00 00 00 00 00 00 10
--
local function make_cooked_netlink_generic_tvb(tvb, offset, length)
    local cooked_hdr = ByteArray.new(
        "00 00 " ..  -- packet type, ignored
        "03 38 " ..  -- ARPHRD_NETLINK
        "00 00 00 00 00 00 00 00 00 00 " .. -- unused 10 bytes
        "00 10"      -- NETLINK_GENERIC
    )

    local netlink_payload = tvb(offset, length):bytes()
    cooked_hdr:append(netlink_payload)

    return cooked_hdr:tvb("Synthetic cooked NETLINK_GENERIC packet")
end

local function dissect_udbg_enh_nlmsghdr_then_netlink(tvb, pinfo, tree, offset, bounded_len)
    local handoff_len = bounded_len
    local synthetic_tvb = make_cooked_netlink_generic_tvb(tvb, offset, handoff_len)

    if netlink_dissector ~= nil then
        netlink_dissector:call(synthetic_tvb, pinfo, tree)
    else
        tree:add_expert_info(PI_UNDECODED, PI_WARN, "netlink dissector not found")
    end

    return offset + handoff_len
end

-- ================= Main dissector =================
function udbg_enh.dissector(tvb, pinfo, tree)
    local caplen = tvb:captured_len()

    if caplen < DEBUG_MSG_HEADER_SIZE then
        return 0
    end

    local msg_type = tvb(8, 4):le_uint()
    local msg_name = udbg_msg_name(msg_type)
    local root = tree:add(udbg_enh, tvb(), "UDBG ENH Protocol (" .. msg_name .. ")")
    set_col(pinfo.cols.protocol, "Udbg_Enh")

    -- Header
    local hdr = root:add(tvb(0, DEBUG_MSG_HEADER_SIZE), "Header")

    hdr:add_le(f_handle, tvb(0, 8))
    hdr:add(f_msg_type, tvb(8, 4), msg_name)
    hdr:add_le(f_timestamp, tvb(12, 8))
    hdr:add_le(f_length, tvb(20, 4))

    local payload_offset = DEBUG_MSG_HEADER_SIZE
    local remaining = caplen - payload_offset

    if remaining <= 0 then
        return caplen
    end

    local body = root:add(tvb(payload_offset, remaining), "Body")

    if msg_type == UDBG_SUBSCRIBE_REQ then
        dissect_subscribe_req_payload(tvb, body, payload_offset, remaining)

    elseif msg_type == UDBG_SUBSCRIBE_RESP then
        dissect_subscribe_resp_payload(tvb, body, payload_offset, remaining)

    elseif msg_type == UDBG_NL_TX or
           msg_type == UDBG_NL_RX or
           msg_type == UDBG_NLCTRL_NL80211 then
        if remaining < 4 then
            return caplen
        end

        body:add_le(f_payload_len, tvb(payload_offset, 4))

        local declared_len = tvb(payload_offset, 4):le_uint()
        local available = remaining - 4
        local bounded_len = math.min(declared_len, available)

        -- Skip only the UDBG payload-length field.
        -- The embedded Netlink message starts immediately after it.
        local log_offset = payload_offset + 4

        dissect_udbg_enh_nlmsghdr_then_netlink(tvb, pinfo, body, log_offset, bounded_len)


    elseif msg_type == UDBG_LOG then
        if remaining < 4 then
            return caplen
        end

        body:add_le(f_payload_len, tvb(payload_offset, 4))

        local declared_len = tvb(payload_offset, 4):le_uint()
        local available = remaining - 4
        local text_len = math.min(declared_len, available)

        if text_len > 0 then
            local log_tvb = tvb(payload_offset + 4, text_len)
            body:add(f_log_text, log_tvb)

            local log_text = log_tvb:string():gsub("%z+$", "")
            if #log_text > 0 then
                set_col(pinfo.cols.info, log_text)
            end
        end

    end

    return caplen
end

-- ================= Registration =================
local encap_table = DissectorTable.get("wtap_encap")
local user0 = (wtap and wtap.USER0) or 45
encap_table:add(user0, udbg_enh)
