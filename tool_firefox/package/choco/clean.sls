# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


Mozilla Firefox is installed:
  chocolatey.uninstalled:
    - name: {{ firefox._pkg.name }}
    - pre_versions: {{ firefox._pkg.pre }}

Mozilla Firefox setup is completed:
  test.nop:
    - name: Hooray, Mozilla Firefox setup has finished.
    - require:
      - chocolatey: {{ firefox._pkg.name }}
