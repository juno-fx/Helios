#!/bin/bash

if [ -x /usr/bin/xfce4-session ]; then
  # Disable compositing
  if [ -f "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml ]; then
    sed -i \
      '/use_compositing/c <property name="use_compositing" type="bool" value="false"/>' \
      "${HOME}"/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
  fi
  /usr/bin/xfce4-session 2>&1
else
  echo "Desktop Environment not found."
  exit 1
fi
