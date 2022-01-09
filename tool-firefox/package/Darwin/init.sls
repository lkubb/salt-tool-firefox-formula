{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- set pkg = salt['match.filter_by']({
  'beta': 'homebrew/cask-versions/firefox-beta',
  'dev': 'homebrew/cask-versions/firefox-developer-edition',
  'esr': 'homebrew/cask-versions/firefox-esr',
  'nightly': 'homebrew/cask-versions/firefox-nightly',
  'stable': 'homebrew/cask/firefox',
  }, minion_id=firefox.version) -%}


Firefox{{ firefox._name_suffix }} is installed:
{# Homebrew always installs latest, mac_brew_pkg does not support upgrading a single package #}
  pkg.installed:
    - name: {{ pkg }}

Firefox{{ firefox._name_suffix }} setup is completed:
  test.nop:
    - name: Firefox{{ firefox._name_suffix }} setup has finished, hooray.
    - require:
      - pkg: {{ pkg }}
