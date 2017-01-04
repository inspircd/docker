#!/bin/sh

for template in "$@"
do
  echo '<include file="/conf/templates/'${template}/${template}'.conf" noexec="no">'
done
