# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch %}

include:
  - {{ tplroot }}.default_profile


{%- for user in firefox.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
{%-   set dotconfig = user.dotconfig if user.dotconfig is mapping else {} %}

Firefox default profile is synced for user '{{ user.name }}':
  file.recurse:
    - name: {{ user._firefox.profile }}
    - source: {{ files_switch(
                ['firefox'],
                default_files_switch=['id', 'os_family'],
                override_root='dotconfig',
                opt_prefixes=[user.name]) }}
    - context:
        user: {{ user | json }}
    - template: jinja
    - user: {{ user.name }}
    - group: {{ user.group }}
{%-   if dotconfig.get('file_mode') %}
    - file_mode: '{{ dotconfig.file_mode }}'
{%-   endif %}
    - dir_mode: '{{ dotconfig.get('dir_mode', '0700') }}'
    - clean: {{ dotconfig.get('clean', false) | to_bool }}
    - makedirs: true
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'
    - onlyif:
      - test -n '{{ user._firefox.profile }}'

Notification about missing default profile for user '{{ user.name }}':
  test.show_notification:
    - text: >
        You will need to run tool_firefox.config a second time since there was no
        default profile for user '{{ user.name }}'. This is a technical limitation
        in the way Salt works.
    - unless:
      - test -n '{{ user._firefox.profile }}'
{%- endfor %}
