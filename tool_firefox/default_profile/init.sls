# -*- coding: utf-8 -*-
# vim: ft=sls

# For notes on this file see DEVLOG.rst in the formula repository.
# This is much more involved than necessary, at some point I want to fix that. @TODO

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package' %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}

include:
  - {{ sls_package_install }}


{%- for user in firefox.users %}

Check if Firefox has created the default user profile for user '{{ user.name }}':
  test.configurable_test_state:
    - changes: false
    - result: false
    - comment: You can ignore this failure, it is a technical workaround.
    - unless:
      - fun: file.find
        path: {{ user._firefox.profiledir }}
        name: '*.{{ firefox._profile_default }}'
        type: d
        maxdepth: 1
    - require:
      - sls: {{ sls_package_install }}

Firefox has been run once for user '{{ user.name }}':
  cmd.run:
    - name: |
        "{{ firefox._bin }}" --headless
    - runas: {{ user.name }}
    # run this in the background
    - bg: true
    # close Firefox after 20s (failsafe for process.absent)
    - timeout: 20
    - hide_output: true
    # only run if the default profile has not been created yet
    - onfail:
      # onfail_stop does not accept state IDs only, needs module: name declaration
      - test: Check if Firefox has created the default user profile for user '{{ user.name }}'
    # this still does not ignore the failure though
    - onfail_stop: false
    - require:
      - sls: {{ sls_package_install }}

# This works as a replacement for nonexistent file.find state
Firefox has created the default user profile for user '{{ user.name }}':
  test.configurable_test_state:
    - changes: false
    # This unreadable mess resulted from several tries of salting this sls file.
    # The result field needs to be either True or False here, cannot be truish/falsey.
    # To cast the result of file.find to bool in a single module call, it needs to be
    # a scripted template. I chose mako because the py renderer does not take string inputs.
    # Actually this could be Jinja if wrapped in raw/endraw tags. @TODO?
    - result: >-
        __slot__:salt:slsutil.renderer(string="[${bool(salt['file.find']('{{ user._firefox.profiledir }}',
        name='*.{{ firefox._profile_default }}', type='d', maxdepth=1))}]", default_renderer='mako|yaml').0
    - comment: This needs to succeed.
    - onchanges:
      - Firefox has been run once for user '{{ user.name }}'
    - retry:
        attempts: 10
        interval: 1

# Close Firefox after the directory has been created if it had to be run.
# Timeout would do this anyways, but this is cleaner.
Firefox does not run for user '{{ user.name }}':
  process.absent:
    - name: {{ salt["file.basename"](firefox._bin) }}
    - user: {{ user.name }}
    - onchanges:
      - Firefox has been run once for user '{{ user.name }}'
{%- endfor %}
