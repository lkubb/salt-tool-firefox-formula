{%- from 'tool-firefox/map.jinja' import firefox -%}

firefox is installed:
{# Homebrew always installs latest, mac_brew_pkg does not support upgrading a single package #}
{%- if firefox.get('update_auto') and not grains['kernel'] == 'Darwin' %}
  pkg.latest:
{%- else %}
  pkg.installed:
{%- endif %}
    - name: {{ firefox._package }}

firefox setup is completed:
  test.nop:
    - name: firefox setup has finished, this state exists for technical reasons.
    - require:
      - pkg: {{ firefox._package }}
