{%- from 'tool-firefox/map.jinja' import firefox -%}

include:
  - .package
{%- if firefox.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
{%- if firefox.get('_policies') or firefox.get('_userjs_source') %}
  - .config
{%- endif %}
