# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

{%- set require_local_sync = firefox.get('_local_extensions') | to_bool
                         and firefox.extensions.local.sync | to_bool %}

{%- if 'Windows' == grains.kernel or require_local_sync %}

include:
{%-   if require_local_sync %}
  - {{ tplroot }}.local_addons
{%-   endif %}
{%-   if 'Windows' == grains.kernel %}
  - {{ slsdotpath }}.winadm
{%-   endif %}
{%- endif %}


{%- if 'Windows' == grains.kernel %}

Firefox policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ firefox._policies | json }}
    - require:
        - sls: {{ slsdotpath }}.winadm
{%-   if require_local_sync %}
        # relative requires do not work,
        # see https://github.com/saltstack/salt/issues/10838
        - sls: {{ tplroot }}.local_addons
{%-   endif %}

Group policies are updated:
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Firefox policies are applied as Group Policy


{%- elif 'Darwin' == grains.kernel %}

Firefox policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.org.mozilla.firefox
    - description: Firefox default configuration managed by Salt state tool_firefox.policies
    - displayname: Firefox configuration (salt-tool)
    - organization: salt.tool
    - removaldisallowed: False
    - ptype: org.mozilla.firefox
    - content:
        - {{ firefox._policies | json }}
{%-   if require_local_sync %}
    - require:
        - sls: {{ tplroot }}.local_addons
{%-   endif %}


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
{%-   if require_local_sync %}
    - require:
        - sls: {{ slspath }}.local_addons
{%-   endif %}
{%- endif %}
