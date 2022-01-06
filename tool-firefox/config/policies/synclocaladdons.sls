{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- if firefox.get('_local_extensions') and firefox.get('ext_local_source_sync') %}
Requested local Firefox addons are synced:
  file.managed:
    - names:
  {%- for extension in local_extensions %}
      {{ firefox.ext_local_source ~ '\\' if 'Windows' == grains.kernel else '/' }}{{ extension }}.xpi:
        - source: salt://user/minimal-firefox/addons/{{ extension }}.xpi
  {%- endfor %}
    - mode: '0644'
    - user: root
    - group: root
    - makedirs: true
{%- endif %}
