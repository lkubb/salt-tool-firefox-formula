# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as firefox with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch %}

include:
  - {{ tplroot }}.default_profile


# This does not make use of the official updater since
# a) the remote should be configurable b) it would always report changes.

{%- for user in firefox.users | selectattr("firefox.userjs", "defined") | selectattr("firefox.userjs", "equalto", "arkenfox") %}

Arkenfox user.js snapshot is updated for user '{{ user.name }}':
  file.managed:
    - name: {{ user._firefox.profile }}user.js.latest
    - source: {{ (
                    files_switch(
                      ["arkenfox/user.js"],
                      lookup="Arkenfox user.js snapshot is updated for user '{}'".format(user.name),
                      config=firefox,
                      custom_data={"users": [user.name]},
                    ) | load_json + [firefox.lookup.arkenfox.base ~ firefox.lookup.arkenfox.user_js]
                 ) | json
              }}
    # # should update the file as well and by default does not use versioned URI
    # - keep_source: false
    # ugly workaround for file caching behavior:
    #   skip_verify: true -> downloads only once
    #   keep_source: false + skip_verify: true -> always changes
    # better solution: https://github.com/saltstack/salt/pull/61391 @FIXME once released
    - source_hash: {{ salt["hashutil.digest"](salt["http.query"](firefox.lookup.arkenfox.base ~ firefox.lookup.arkenfox.user_js).body) }}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      - Firefox has created the default user profile for user '{{ user.name }}'

Arkenfox user.js overrides are present for user '{{ user.name }}':
  file.managed:
    - name: {{ user._firefox.profile }}user-overrides.js
    - source: {{ files_switch(
                    ["arkenfox/user-overrides.js", "arkenfox/user-overrides.js.j2"],
                    lookup="Arkenfox user.js overrides are present for user '{}'".format(user.name),
                    config=firefox,
                    custom_data={"users": [user.name]},
                 )
              }}
    - template: jinja
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - context:
        user: {{ user | json }}

Arkenfox user.js is updated for user '{{ user.name }}':
  file.copy:
    - name: {{ user._firefox.profile }}user.js
    - source: {{ user._firefox.profile }}user.js.latest
    - force: true
    # preserve did not work
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - onchanges:
      - Arkenfox user.js snapshot is updated for user '{{ user.name }}'
      - Arkenfox user.js overrides are present for user '{{ user.name }}'

{%-   if "esr" == firefox.version %}

Arkenfox user.js ESR-related settings are active for user '{{ user.name }}':
  file.replace:
    - name: {{ user._firefox.profile }}user.js
    - pattern: \/\* (ESR[0-9]{2,}\.x still uses all.*)
    - repl: // \1
    - backup: false
    - ignore_if_missing: false
    - onchanges:
      - Arkenfox user.js is updated for user '{{ user.name }}'
    - require_in:
      - Arkenfox user.js overrides are appended for user '{{ user.name }}'
{%-   endif %}

Arkenfox user.js overrides are appended for user '{{ user.name }}':
  file.append:
    - name: {{ user._firefox.profile }}user.js
    - sources:
      - {{ user._firefox.profile }}user-overrides.js
    - onchanges:
      - Arkenfox user.js is updated for user '{{ user.name }}'

{%-   if user | traverse("firefox:arkenfox:autoclean_prefs") %}

Firefox is not running before cleaning prefs for user '{{ user.name }}':
  process.absent:
    - name: {{ salt["file.basename"](firefox._bin) }}
    - user: {{ user.name }}
    - onchanges:
      - Arkenfox user.js snapshot is updated for user '{{ user.name }}'
    # https://github.com/saltstack/salt/issues/60641
    # - prereq:
    #   - Arkenfox prefsCleaner has cleaned prefs.js for user '{{ user.name }}'

# The official prefsCleaners do not allow to be run with an arbitrary
# current working directory (always `cd`s to its path).
# The official prefsCleaner.bat furthermore does not allow noninteractive usage.
# The scripts included in this formula have been modified to fit this specific use case.
Arkenfox prefsCleaner has cleaned prefs.js for user '{{ user.name }}':
  cmd.script:
    # cmd.script does not allow for list of sources
    - source: salt://{{ tplroot }}/files/default/arkenfox/prefsCleaner{{ ".sh" if grains.os != "Windows" else ".bat" }}
{%-     if grains.os != "Windows" %}
    - args: -s
{%-     endif %}
    - cwd: {{ user._firefox.profile[:-1] }}
    - runas: {{ user.name }}
    - onchanges:
      - Arkenfox user.js snapshot is updated for user '{{ user.name }}'
    - require:
      - Firefox is not running before cleaning prefs for user '{{ user.name }}'
{%-   endif %}
{%- endfor %}
