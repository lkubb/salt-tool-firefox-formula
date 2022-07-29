# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

{%- set require_local_sync = firefox.get('_local_extensions') | to_bool
                         and firefox.extensions.local.sync | to_bool %}

{%- if 'Windows' == grains.kernel or require_local_sync %}
include:
{%-   if require_local_sync %}
  - {{ tplroot }}.local_addons.clean
{%-   endif %}
{%-   if 'Windows' == grains.kernel %}
  - {{ slsdotpath }}.winadm.clean
{%-   endif %}
{%- endif %}


{%- if 'Windows' == grains.kernel %}

Firefox policies are removed from Group Policy:
  lgpo.set:
    - computer_policy: {}
    - require_in:
        # this might very well not be allowed, @FIXME?
        - sls: {{ slsdotpath }}.winadm.clean

Group policies are updated:
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Firefox policies are removed from Group Policy


{%- elif 'Darwin' == grains.kernel %}

Firefox policy profile cannot be silently removed:
  test.show_notification:
    - text: >
        Salt cannot silently remove an installed system profile.
        You will need to do that manually. See
            System Preferences > Profiles

{%- else %}

Firefox policies are absent:
  file.absent:
    - name: {{ firefox._path }}/distribution/policies.json
{%- endif %}
