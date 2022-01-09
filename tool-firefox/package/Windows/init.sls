{%- from 'tool-firefox/map.jinja' import firefox -%}

{#- prereleases need --pre flag on Windows -#}
{%- set pkg = salt['match.filter_by']({
  'beta': {
    'name': 'firefox-beta',
    'pre': True,
  },
  'dev': {
    'name': 'firefox-dev',
    'pre': True,
  },
  'esr': {
    'name': 'firefoxesr',
    'pre': False,
  },
  'nightly': {
    'name': 'firefox-nightly',
    'pre': True,
  },
  'stable': {
    'name': 'firefox',
    'pre': False
  }}, minion_id=firefox.version) -%}


Firefox{{ firefox._name_suffix }} is installed:
{%- if firefox.get('update_auto') %}
  chocolatey.upgraded:
{%- else %}
  chocolatey.installed:
{%- endif %}
    - name: {{ pkg.name }}
    - pre_versions: {{ pkg.pre }}

Firefox{{ firefox._name_suffix }} setup is completed:
  test.nop:
    - name: Firefox{{ firefox._name_suffix }} setup has finished, hooray.
    - require:
      - chocolatey: {{ pkg.name }}
