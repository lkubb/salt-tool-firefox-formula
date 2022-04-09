# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package' %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - {{ sls_package_install }}


{%- for user in firefox.users %}

Firefox has created the default user profile for user '{{ user.name }}':
  cmd.run:
    - name: |
        ffexecutable='{{ firefox._bin }}'
        eval "${ffexecutable} --headless &"
        sleep 10
        killall -HUP firefox
        find '{{ user._firefox.profiledir }}/*{{ firefox._profile_default }}'
    - runas: {{ user.name }}
    - unless: # this might not work on windows @FIXME
      - test -n '{{ user._firefox.profile }}'
    - require:
      - sls: {{ sls_package_install }}
{%- endfor %}
