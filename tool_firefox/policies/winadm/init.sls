# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


# reference: https://github.com/dafyddj/firefox-formula/blob/master/firefox/gpo/install/init.sls
{%- if 'Windows' == grains.kernel %}
{%-   set l = firefox.lookup.win_gpo %}
{%-   for template in ['firefox', 'mozilla'] %}

{{ template | capitalize }} GPO ADMX file is installed:
  file.managed:
    - name: {{ l.policy_dir | path_join(template ~ '.admx') }}
    - source: https://raw.githubusercontent.com/mozilla/policy-templates/v{{ l.policy_revision }}/windows/{{ template }}.admx
    - source_hash: {{ l.hashes[l.policy_revision][template].admx }}
    - win_owner: {{ l.owner }}

{{ template | capitalize }} GPO ADML file is installed:
  file.managed:
    - name: {{ l.policy_dir | path_join(l.lang, template ~ '.adml') }}
    - source: https://raw.githubusercontent.com/mozilla/policy-templates/v{{ l.policy_revision }}/windows/{{ l.lang }}/{{ template }}.adml
    - source_hash: {{ l.hashes[l.policy_revision][template].adml }}
    - win_owner: {{ l.owner }}
{%-   endfor %}
{%- endif %}
