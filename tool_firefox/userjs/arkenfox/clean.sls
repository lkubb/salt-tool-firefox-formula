# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- for user in firefox.users | selectattr("firefox.userjs", "defined") | selectattr("firefox.userjs", "sameas", "arkenfox") %}

Firefox default profile user.js is absent for user '{{ user.name }}':
  file.absent:
    - names:
      - __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d').0 ~ /user.js
      - __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d').0 ~ /user.js.latest
      - __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d').0 ~ /user-overrides.js
{%- endfor %}
