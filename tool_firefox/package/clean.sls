# vim: ft=sls

{#-
    Removes the Mozilla Firefox package.
    Has a dependency on `tool_firefox.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - .{{ firefox._pkg.type }}.clean
