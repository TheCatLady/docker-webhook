#!/usr/bin/env sh

[[ "${WEBHOOK_DEBUG}" == "true" ]] && export WEBHOOK_DEBUG="-debug"
[[ "${WEBHOOK_HOTRELOAD}" == "true" ]] && export WEBHOOK_HOTRELOAD="-hotreload"

exec /usr/local/bin/webhook ${WEBHOOK_DEBUG} ${WEBHOOK_HOTRELOAD} -hooks hooks.yaml
