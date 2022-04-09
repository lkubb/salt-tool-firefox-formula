# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


Mozilla Firefox is installed:
  chocolatey.installed:
    - name: {{ firefox._pkg.name }}
    - pre_versions: {{ firefox._pkg.pre }}
