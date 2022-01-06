{%- from 'tool-firefox/map.jinja' import firefox -%}

include:
  - .config.profile

{%- for user in firefox.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}

Firefox default profile is synced from dotfiles for user '{{ user.name }}':
  file.recurse:
    - name: {{ user._firefox.profile or '/tmp/removeme37bf74bf021cb2c9f' }}
    - source:
      - salt://dotconfig/{{ user.name }}/firefox
      - salt://dotconfig/firefox
    - context:
        user: {{ user }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - file_mode: keep
    - dir_mode: '0700'
    - makedirs: False
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'
    - onlyif:
      - test -n "{{ user._firefox.profile }}"
{%- endfor %}
