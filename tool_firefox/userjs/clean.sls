# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- for user in firefox.users | selectattr('firefox.userjs', 'defined') | selectattr('firefox.userjs') %}

Firefox default profile user.js is synced with source for user '{{ user.name }}':
  file.absent:
    - name: {{ user._firefox.profile }}/user.js
    - onlyif:
      - test -n '{{ user._firefox.profile }}'
{%- endfor %}
