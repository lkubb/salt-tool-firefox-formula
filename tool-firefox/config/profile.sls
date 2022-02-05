{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- for user in firefox.users %}
Firefox has created the default user profile for user '{{ user.name }}':
  cmd.run:
    - name: |
        ffexecutable=$(command -v firefox || echo -n '{{ firefox._bin }}')
        eval "${ffexecutable} --headless &"
        sleep 10
        killall -HUP firefox
        find "{{ user._firefox.confdir }}/*{{ user._firefox.default_profile }}"
    - runas: {{ user.name }}
    - unless: # this might not work on windows @FIXME
      - test -n "{{ user._firefox.profile }}"
{%- endfor %}
