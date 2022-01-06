{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- if firefox.get('_policies') or firefox.get('_userjs_source') -%}
include:
  {%- if firefox.get('_policies') %}
  - .policies
  {%- endif %}
  {%- if firefox.get('_userjs_source') %}
  - .userjs
  {%- endif %}
{%- endif %}
