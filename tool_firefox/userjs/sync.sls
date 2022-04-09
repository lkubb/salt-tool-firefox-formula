# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - {{ tplroot }}.default_profile


# @FIXME for global installation and this to make sense
# see https://github.com/pyllyukko/user.js/#system-wide-installation-all-platforms

# Jinja will be evaluated before the states are run, therefore it cannot find the profile dir
# while Firefox is not installed (on the first run). Implement execution module to change that @TODO.

{%- for user in firefox.users | selectattr('firefox.userjs', 'defined') | selectattr('firefox.userjs') %}

Firefox default profile user.js is synced with source for user '{{ user.name }}':
  file.managed:
    - name: {{ user._firefox.profile }}/user.js
    - source: {{ firefox._userjs_source }}
  {%- if firefox.get('_userjs_hash') %}
    - source_hash: {{ firefox._userjs_hash }}
  {%- else %}
    - skip_verify: true  # this is needed for arbitrary user.js files
  {%- endif %}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'
    - onlyif:
      - test -n '{{ user._firefox.profile }}'
{%- endfor %}
