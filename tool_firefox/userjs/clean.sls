# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - {{ tplroot }}.userjs.arkenfox.clean

{%- for user in firefox.users | selectattr("firefox.userjs", "defined") | selectattr("firefox.userjs") | rejectattr("firefox.userjs", "equalto", "arkenfox") %}

Firefox default profile user.js is synced with source for user '{{ user.name }}':
  file.absent:
    - name: {{ user._firefox.profile }}user.js
{%- endfor %}
