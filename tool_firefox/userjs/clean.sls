# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}


{%- for user in firefox.users | selectattr('firefox.userjs', 'defined') | selectattr('firefox.userjs') %}

Firefox default profile user.js is synced with source for user '{{ user.name }}':
  file.absent:
    # it seems maxdepth=1 is parsed as a str, not int, resulting in an exception: `self.maxdepth is None or self.maxdepth >= depth`
    # - name: __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d', maxdepth=1).0 ~ /user.js
    - name: __slot__:salt:file.find('{{ user._firefox.profiledir }}', name='*{{ firefox._profile_default }}', type='d').0 ~ /user.js
{%- endfor %}
