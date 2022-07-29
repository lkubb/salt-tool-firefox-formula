# -*- coding: utf-8 -*-
# vim: ft=sls

# This file exists to make sure the default profile has been generated.
# It is the result of a lot of trial and error testing.
# Previously, it was just a call to cmd.run that ran a script along the lines of:

#   eval "${ff_bin} --headless &"
#   until find $ff_profile -type d -maxdepth 0; do
#     sleep 1
#   done
#   sleep 1
#   killall -15 firefox
#   find $ff_profile -type d -maxdepth 0

# That implementation is I) not portable II) requires two state runs and III) ugly.
# The solution down below works as follows:
#   * checks if the profile exists
#   * if not, runs Firefox in the background
#   * checks for the existence of the profile by reporting the output of file.find
#     using configurable_test_state with __slot__, retrying on failure
#   * the slot needs to cast file.find output to boolean, which is done using
#     slsutil.renderer with a mako template string (to avoid premature Jinja rendering,
#     but this could have been solved by raw/endraw tags as well)
#   * the template returns the boolean output inside a list since False automatically changes to None
#   * the slot then takes the first element of that list and returns it as the value
#     for the configurable test result

# The heart of the problem is that the profile dir is random and file.exists state does not take globs.
# The best solution would have been to write a state module function for file.find ~ file.exists, but I wanted to avoid custom modules for unrelated stuff here.
# It would have been helpful to have more flexible slots: https://github.com/saltstack/salt-enhancement-proposals/pull/33
# Some solutions I tried to determine if the profile exists:
# X different variants of module.run/test.* + unless, check_cmd, prereq, retry
# X test.fail_with_changes + unless file.find + prereq
#     -> prereq implies require X
#     -> unless with fun: and retry does not work (fun: seems to be popped from the dict after the first run)
#   Solution:
#     -> split the first check/trigger and the retry checks
#     -> use slots to call file.find directly and report its state via configurable test state

# Issues I stumbled upon:
# * module.run + retry: https://github.com/saltstack/salt/issues/49895
# * module.run + unless: fun always reported changes
# * __slots__ do not allow casting of values
# * py renderer does not allow string input/chaining
#     https://github.com/saltstack/salt/issues/45521
#     https://github.com/saltstack/salt/pull/55390
# * if a renderer only returns False, it will be changed to None
# * unless with fun: and retry does not work (fun is missing after first try)
# * onfail_stop does not take state IDs only
# * onfail_stop does not actually "catch" failures (https://github.com/saltstack/salt/issues/16291)

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
        name: '*{{ firefox._profile_default }}'
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
        name='*{{ firefox._profile_default }}', type='d', maxdepth=1))}]", default_renderer='mako|yaml').0
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
