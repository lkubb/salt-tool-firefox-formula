# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}
{%- set sls_actual_install = slsdotpath ~ '.' ~ firefox._pkg.type %}

include:
  - {{ sls_actual_install }}


# this needs to be here to be able to require this sls file
Mozilla Firefox setup is completed:
  test.nop:
    - name: Hooray, Mozilla Firefox setup has finished.
    - require:
      - sls: {{ sls_actual_install }}
