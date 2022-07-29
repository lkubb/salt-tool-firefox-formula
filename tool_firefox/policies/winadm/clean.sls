# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


# reference: https://github.com/dafyddj/firefox-formula/blob/master/firefox/gpo/install/init.sls
{%- if 'Windows' == grains.kernel %}
{%-   set l = firefox.lookup.win_gpo %}
{%-   for template in ['firefox', 'mozilla'] %}

{{ template | capitalize }} GPO ADMX file is absent:
  file.absent:
    - name: {{ l.policy_dir | path_join(template ~ '.admx') }}

{{ template | capitalize }} GPO ADML file is absent:
  file.absent:
    - name: {{ l.policy_dir | path_join(l.lang, template ~ '.adml') }}
{%-   endfor %}
{%- endif %}
