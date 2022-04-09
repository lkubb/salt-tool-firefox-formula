# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- for user in firefox.users %}

Mozilla Firefox config dir is absent for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_firefox'].profiles }}
{%- endfor %}
