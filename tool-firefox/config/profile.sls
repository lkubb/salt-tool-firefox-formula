{%- from 'tool-firefox/map.jinja' import firefox -%}

# need the default profile name, should be default-release in most cases. not sure which ones use default
{%- set profilename = 'default-release' if firefox.version in ['esr', 'stable'] else 'default' -%}

{%- for user in firefox.users %}
Firefox has created the default user profile for user '{{ user.name }}':
  cmd.run:
    - name: |
        ffexecutable=$(command -v firefox{{ firefox._esr }} || '{{ firefox._default_path }}')
        eval "${ffexecutable} --headless &"
        sleep 10
        killall -HUP firefox{{ firefox._esr }}
    - runas: {{ user.name }}
    - unless: # this might not work on windows @FIXME
      - test -n "{{ user._firefox.profile }}"
{%- endfor %}
