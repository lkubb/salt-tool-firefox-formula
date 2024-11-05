# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if firefox.get("_local_extensions") and firefox.extensions.local.sync %}

Requested local Firefox addons are synced:
  file.managed:
    - names:
{%-   for extension in firefox._local_extensions %}
      - {{ firefox.extensions.local.source | path_join(extension ~ ".xpi") }}:
        - source: {{ files_switch([extension ~ ".xpi"],
                              lookup="Requested local Firefox addons are synced",
                              indent_width=10,
                              override_root=tplroot ~ "/addons")
                  }}
{%-   endfor %}
    - mode: '0644'
    - user: root
    - group: {{ firefox.lookup.rootgroup }}
    - makedirs: true
{%- endif %}
