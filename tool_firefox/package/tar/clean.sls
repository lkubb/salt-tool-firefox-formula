# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


Mozilla Firefox is absent:
  file.absent:
    - name: {{ firefox._path }}
