# vim: ft=sls

{#-
    Manages the Mozilla Firefox package configuration by

    * recursively syncing from a dotfiles repo

    Has a dependency on `tool_firefox.package`_.
#}

include:
  - .sync
