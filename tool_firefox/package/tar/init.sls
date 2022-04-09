# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


# Just dump the archive contents for the moment.
# This will break automatic updates since root owns those files.
# Revisit this whole mess later @TODO
# (consider installing per user, as Tor Browser does)
Mozilla Firefox is installed:
  archive.extracted:
    - name: {{ firefox._path }}
    # I remember needing double {{ }} for this command for some reason,
    # but will need to check again @FIXME
    - source: {{ salt['cmd.run_stdout'](
        "curl -ILs -o /dev/null -w %{url_effective} '" ~
        firefox._pkg.url ~ "'") }}
    - skip_verify: true # unsafe, does not work without atm
