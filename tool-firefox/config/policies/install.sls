{%- from 'tool-firefox/map.jinja' import firefox -%}

{%- set require_local_sync = firefox.get('_local_extensions') | to_bool
                         and firefox.get('ext_local_source_sync') | to_bool -%}

{%- if 'Windows' == grains.kernel or require_local_sync %}
include:
  {%- if require_local_sync %}
  - .synclocaladdons
  {%- endif %}
  {%- if 'Windows' == grains.kernel %}
  - .winadm
  {%- endif %}
{%- endif %}

{%- if 'Windows' == grains.kernel %}

Firefox policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ firefox._policies | json }}
    - require:
        - sls: {{ slsdotpath }}.winadm
  {%- if require_local_sync %}
        - sls: {{ slsdotpath }}.synclocaladdons
  {%- endif %}

Group policies are updated:
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Firefox policies are applied as Group Policy

{%- elif 'Darwin' == grains.kernel %}

Firefox policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.org.mozilla.firefox
    - description: Firefox default configuration managed by Salt state tool-firefox.config.policies
    - organization: salt.tool
    - removaldisallowed: False
    - ptype: org.mozilla.firefox
    - content:
        - {{ firefox._policies | json }}
  {%- if require_local_sync %}
    - require:
        - sls: {{ slsdotpath }}.synclocaladdons # relative requires do not work, see https://github.com/saltstack/salt/issues/10838
  {%- endif %}
{%- else %}

Firefox policies are synced to policies.json:
  file.serialize:
    - name: {{ firefox._path }}/distribution/policies.json
    - dataset: {{ {'policies': firefox._policies} | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: root
    - mode: '0644'
  {%- if require_local_sync %}
    - require:
        - sls: {{ slspath }}.synclocaladdons
  {%- endif %}
{%- endif %}
