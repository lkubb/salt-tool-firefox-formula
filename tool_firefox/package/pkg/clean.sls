# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- if grains.os == "Debian" %}

# unsure if resetting this interferes too much
Debian unstable repository is inactive:
  pkgrepo.absent:
    - humanname: Debian unstable
    - name: deb http://deb.debian.org/debian/ unstable main contrib non-free
    - file: /etc/apt/sources.list

Debian unstable repository is not pinned to low priority:
  file.absent:
    - name: /etc/apt/preferences.d/99pin-unstable
{%- endif %}

Mozilla Firefox is removed:
  pkg.removed:
    - name: {{ firefox._pkg.name }}
