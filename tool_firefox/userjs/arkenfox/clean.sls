# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- for user in firefox.users | selectattr("firefox.userjs", "defined") | selectattr("firefox.userjs", "sameas", "arkenfox") %}

Firefox default profile user.js is absent for user '{{ user.name }}':
  file.absent:
    - names:
      - {{ user._firefox.profile }}user.js
      - {{ user._firefox.profile }}user.js.latest
      - {{ user._firefox.profile }}user-overrides.js
{%- endfor %}
