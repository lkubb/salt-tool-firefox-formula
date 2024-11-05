# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- if grains.os == "Debian" and firefox.version != "esr" %}

Ensure Debian unstable repository can be managed:
  pkg.installed:
    - pkgs:
      - python-apt

# Debian only distributes Firefox ESR in stable repository, need unstable for stable >.<
Debian unstable repository is active:
  pkgrepo.managed:
    - humanname: Debian unstable
    - name: deb http://deb.debian.org/debian/ unstable main contrib non-free
    - file: /etc/apt/sources.list

Debian unstable repository is pinned to low priority to not install all unstable packages:
  file.managed:
    - name: /etc/apt/preferences.d/99pin-unstable
    - contents: |
        Package: *
        Pin: release a=stable
        Pin-Priority: 900

        Package: *
        Pin: release a=unstable
        Pin-Priority: 10
{%- endif %}

Mozilla Firefox is installed:
  pkg.installed:
    - name: {{ firefox._pkg.name }}
{%- if grains.os == "Debian" and firefox.version != "esr" %}
    - refresh: true
{%- endif %}
