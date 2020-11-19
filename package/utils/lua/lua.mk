#
# Recipe extension for lua
#

LUA_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
HOST_PATCH_DIR := $(LUA_DIR)/patches-host
