{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- set installation = salt['match.filter_by']({
  'esr': {
    'type': 'pkg',
    'pkgname': 'firefox-esr'},
  'stable': {
    'type': 'pkg',
    'pkgname': 'firefox',
    'refresh': True},
  'dev': {
    'type': 'tar',
    'url': 'https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux'},
  'beta': {
    'type': 'tar',
    'url': 'https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=linux'},
  'nightly': {
    'type': 'tar',
    'url': 'https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux'}
  }, minion_id=firefox.version) -%}

{#- this is untested so far, treat it like documentation atm #}
{%- if 'stable' == firefox.version %}

Ensure Debian repositories can be managed by tool-firefox:
  pkg.installed:
    - pkgs:
      - python-apt

# Debian only distributes Firefox ESR in stable repository, need unstable
Debian unstable repository is active to be able to install Firefox latest stable release:
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

{%- if installation.type == 'pkg' %}

Firefox{{ firefox._name_suffix }} is installed:
  {%- if firefox.get('update_auto') %}
  pkg.latest:
  {%- else %}
  pkg.installed:
  {%- endif %}
    - name: {{ installation.pkgname }}
    - refresh: {{ installation.refresh | default(False) }}

Firefox{{ firefox._name_suffix}} setup is completed:
  test.nop:
    - name: Firefox{{firefox._name_suffix}} setup has finished, hooray.
    - require:
      - pkg: {{ installation.pkgname }}

{%- elif installation.type == 'tar' %}

{%- set source = salt['cmd.run_stdout']("curl -ILs -o /dev/null -w %{url_effective} 'https://download.mozilla.org/?product=firefox-{{ version }}-latest-ssl&os=linux'" | format(version)) %}
# just dump the archive into /opt. this will break automatic update since root owns those files
# revisit this whole mess later @TODO (consider installing per user, as Tor Browser does)
Firefox{{ firefox._name_suffix }} is installed:
  archive.extracted:
    - name: /opt/firefox-{{ firefox.version }}
    - source: {{ source }}
    - skip_verify: True # unsafe, does not work without atm
{%- endif %}
