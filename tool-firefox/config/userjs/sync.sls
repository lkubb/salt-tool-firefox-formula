{%- from 'tool-firefox/map.jinja' import firefox -%}

include:
  - ..profile

# @FIXME for global installation and this to make sense
# see https://github.com/pyllyukko/user.js/#system-wide-installation-all-platforms

{%- for user in firefox.users | selectattr('userjs', 'defined') | selectattr('userjs') %}
# jinja will be evaluated before the states are run, therefore jinja cannot find the profile dir
# while firefox is not installed (on the first run). implement execution module to change that @TODO
Firefox default profile user.js is synced with source for user {{ user.name }}:
  file.managed:
    - name: {{ user._firefox.profile }}/user.js
    - source: {{ firefox._userjs_source }}
  {%- if firefox.get('_userjs_hash') %}
    - source_hash: {{ firefox._userjs_hash }}
  {%- else %}
    - skip_verify: True # this is needed for arbitrary user.js files
  {%- endif %}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'
    - onlyif:
      - test -n "{{ user._firefox.profile }}"
{%- endfor %}
