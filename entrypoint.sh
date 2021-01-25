#!/usr/bin/env sh

[ "${WEBHOOK_VERBOSE}" = "true" ] && export WEBHOOK_VERBOSE="-verbose"
[ "${WEBHOOK_HOTRELOAD}" = "true" ] && export WEBHOOK_HOTRELOAD="-hotreload"

exec /usr/local/bin/webhook ${WEBHOOK_DEBUG} ${WEBHOOK_HOTRELOAD} -hooks hooks.yaml
