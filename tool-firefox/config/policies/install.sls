{%- from 'tool-firefox/map.jinja' import firefox -%}

include:
  - .synclocaladdons
{%- if 'Windows' == grains.kernel %}
  - .winadm

Firefox policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ firefox._policies | json }}
    - require:
      - sls: {{ slspath }}.winadm
      - sls: {{ slspath }}.synclocaladdons

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
    - require:
      - sls: {{ slspath }}.synclocaladdons # relative requires do not work, see https://github.com/saltstack/salt/issues/10838

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
    - require:
      - sls: {{ slspath }}.synclocaladdons
{%- endif %}
