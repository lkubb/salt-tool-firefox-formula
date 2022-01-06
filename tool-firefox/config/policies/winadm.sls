{%- from 'tool-firefox/map.jinja' import firefox -%}
{%- import_yaml 'tool-firefox/config/policies/files/windows_gpo_source_hashes.yml' as gpo_hashes -%}

{%- load_yaml as gpo -%}
revision: {{ firefox.win_gpo_policy_revision | default('3.4') }}
lang: {{ firefox.win_gpo_lang | default('en_US') }}
dir: {{ firefox.win_gpo_policy_dir | default('C:\\Windows\\PolicyDefinitions') }}
owner: {{ firefox.win_gpo_owner | default('Administrators') }}
{%- endload -%}

{#- add hashes after to avoid repetition. default adml hashes are for en_US -#}
{%- do gpo.update({'hashes': firefox.get('win_gpo_hashes', gpo_hashes[gpo.revision])}) %}

# reference: https://github.com/dafyddj/firefox-formula/blob/master/firefox/gpo/install/init.sls
{%- if 'Windows' == grains.kernel %}
  {% for template in ['firefox', 'mozilla'] %}
{{ template | capitalize }} GPO ADMX file is installed:
  file.managed:
    - name: {{ gpo.dir }}\{{ template }}.admx
    - source: https://github.com/mozilla/policy-templates/raw/v{{ gpo.revision }}/windows/{{ template }}.admx
    - source_hash: {{ gpo.hashes[template].admx }}
    - win_owner: {{ gpo.owner }}

{{ template | capitalize }} GPO ADML file is installed:
  file.managed:
    - name: {{ gpo.dir }}\{{ gpo.lang }}\{{ template }}.adml
    - source: https://github.com/mozilla/policy-templates/raw/v{{ gpo.revision }}/windows/{{ gpo.lang }}/{{ template }}.adml
    - source_hash: {{ gpo.hashes[template].adml }}
    - win_owner: {{ gpo.owner }}
  {% endfor %}
{%- endif %}
