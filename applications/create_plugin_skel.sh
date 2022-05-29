#!/bin/bash
# Author: Silas Cutler

PLUGIN_NAME_u=$1
PLUGIN_NAME=${1^^}

mkdir -p $PLUGIN_NAME_u
touch $PLUGIN_NAME_u/$PLUGIN_NAME_u.c


# Creates templated entries for required references
APP_LIST_ENTRY=$(cat << EOM
const FlipperApplication FLIPPER_PLUGINS[] = {

#ifdef APP_$PLUGIN_NAME
    {.app = ${PLUGIN_NAME_u}_app, 
    .name = "$PLUGIN_NAME_u", 
    .stack_size = 1024, 
    .icon = &A_Plugins_14,
    .flags = FlipperApplicationFlagDefault},
#endif

EOM
)

APP_LIST_I=$(cat << EOM
// Plugins	
extern int32_t ${PLUGIN_NAME_u}_app(void* p);
EOM
)

APPMK_LIST_I=$(cat << EOM
# Plugins
APP_${PLUGIN_NAME} = 1
EOM
)

APPMK_LIST_ENTRY=$(cat << EOM
# Prefix with APP_*

APP_${PLUGIN_NAME} ?= 0
ifeq (\$(APP_${PLUGIN_NAME}), 1)
CFLAGS		+= -DAPP_${PLUGIN_NAME}
SRV_GUI		= 1
endif
EOM
)

# Assemble applications.mk
APPMKFILE=$(cat applications.mk)
APPMKFILE="${APPMKFILE/'# Plugins'/$APPMK_LIST_I}"
APPMKFILE="${APPMKFILE/'# Prefix with APP_*'/$APPMK_LIST_ENTRY}"

# Overwrite to replace
echo "$APPMKFILE" > applications.mk

# Assemble applications.c
APPFILE=$(cat applications.c)
APPFILE="${APPFILE/'// Plugins'/$APP_LIST_I}"
APPFILE="${APPFILE/'const FlipperApplication FLIPPER_PLUGINS[] = {'/$APP_LIST_ENTRY}"

# Overwrite to replace
echo "$APPFILE" > applications.c

echo "[+] Done!"