# vim: ft=yaml
# yamllint disable rule:comments-indentation
---
tool_global:
  users:
    user:
      completions: .completions
      configsync: true
      persistenv: .bash_profile
      rchook: .bashrc
      xdg: true
      firefox:
        arkenfox:
          autoclean_prefs: true
          override:
            autosearch: false
            drm: false
            form_autofill: false
            history_keep: false
            letterboxing_disabled: false
            referrer_always: false
            rfp_disabled: false
            safe_browsing_download_remote_lookup: false
            session_restore: false
            strict_pinning_disabled: false
            webgl: false
          override_custom: {}
        userjs:
          hash: false
          source: https://raw.githubusercontent.com/arkenfox/user.js/master/user.js
tool_firefox:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value

    pkg:
      name: firefox
    paths:
      confdir: '.mozilla/firefox'
      conffile: 'config'
    rootgroup: root
  extensions:
    absent:
      - tampermonkey
    defaults:
      installation_mode: normal_installed
      updates_disabled: false
    local:
      source: /opt/firefox_addons
      sync: true
    wanted:
      - bitwarden
      - ublock-origin:
          installation_mode: force_installed
      - metamask:
          local: true
  policies:
    DisableTelemetry: true
    NoDefaultBookmarks: true
    OverrideFirstRunPage: about:blank
    OverridePostUpdatePage: about:blank
  version: esr

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://tool_firefox/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   tool-firefox-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
