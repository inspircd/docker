# CLOAKING

This config template enables cloaking module.

We provide only `full` or `half` cloaking mode.

## Configuration

|Variables |Default value|Description|
|----------|-------------|-----------|
|INSPG_CLOAKING_MODE|`full`|Name of the cloaking mode. Alternative: `half`|
|INSPG_CLOAKING_KEY|Random generated password|Secret which is used for cloaking. Default value uses 512 random chars|
|INSPG_CLOAKING_PREFIX|empty|Is written before the cloaked IP string|
|INSPG_CLOAKING_SUFFIX|`.cloak` + INSP_NET_SUFFIX|Is written behind the cloaked IP string|

## Enable config

Add `cloaking` to the environment variable `INSP_ENABLE_TEMPLATES`.

Example:

```console
docker run --name ircd -e INSP_ENABLE_TEMPLATES="cloaking" -p 6667:6667 inspircd/inspircd-docker
```
