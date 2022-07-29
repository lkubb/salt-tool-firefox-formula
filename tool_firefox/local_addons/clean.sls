# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- if firefox.get('_local_extensions') and firefox.extensions.local.sync %}

Synced local Firefox addons are absent:
  file.absent:
    - names:
{%-   for extension in firefox._local_extensions %}
      - {{ firefox.extensions.local.source | path_join(extension ~ '.xpi') }}
{%-   endfor %}
{%- endif %}
