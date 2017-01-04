#!/bin/sh

[ -z "$INSPG_CLOAKING_KEY" ] && echo '<define name="inspgCloakingKey" value="'$(dd if=/dev/urandom bs=1 count=512 2>/dev/null | base64 | rev | cut -b 2- | rev)'">'
[ "$INSPG_CLOAKING_MODE" = "half" ] || echo '<define name="inspgCloakingMode" value="full">'
[ -z "$INSPG_CLOAKING_PREFIX" ] && echo '<define name="inspgCloakingPrefix" value="">'
[ -z "$INSPG_CLOAKING_SUFFIX" ] && echo '<define name="inspgCloakingSuffix" value=".cloak&netsuffix;">'
