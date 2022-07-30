# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - {{ tplroot }}.default_profile
  - {{ tplroot }}.userjs.arkenfox


# @FIXME for global installation and this to make sense
# see https://github.com/pyllyukko/user.js/#system-wide-installation-all-platforms

{%- for user in firefox.users | selectattr('firefox.userjs', 'defined') | selectattr('firefox.userjs') | rejectattr('firefox.userjs', 'equalto', 'arkenfox') %}

Firefox default profile user.js is synced with source for user '{{ user.name }}':
  file.managed:
    # https://github.com/saltstack/salt/issues/61572
    # it seems maxdepth=1 is parsed as a str, not int, resulting in an exception: `self.maxdepth is None or self.maxdepth >= depth`
    - name: __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d').0 ~ /user.js
    - source: {{ user | traverse("firefox:userjs:source", user.firefox.userjs) }}
  {%- if user | traverse("firefox:userjs:hash") %}
    - source_hash: {{ user.firefox.userjs.hash }}
  {%- else %}
    - skip_verify: true  # this is needed for arbitrary user.js files
  {%- endif %}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'
{%- endfor %}
