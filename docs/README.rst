.. _readme:

Mozilla Firefox Formula
=======================

Manages Mozilla Firefox browser in the user environment.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_firefox`` will make sure Firefox is configured as specified.

Local sources
~~~~~~~~~~~~~
This formula provides a way to automatically install extensions from a local source. This provides you with more control about which versions you use and when you want to update.

Generally, local extensions need to be found on the minion under the path specified by ``extensions:local:source``, named ``<extension_name>.xpi``. E.g. for uBlock Origin on Linux, this would be ``/opt/firefox_addons/ublock-origin.xpi`` by default.

If you enable syncing local sources from the fileserver by setting ``extensions:local:sync`` to ``true``, you will need to provide those extensions on the fileserver. The state uses a slightly modified TOFS pattern, as most ``tool`` formulae do. By default, the extensions need to be found in one of the following paths (descending priority):

* ``salt://tool_firefox/addons/<minion_id>/<extension_name>.xpi``
* ``salt://tool_firefox/addons/<os_family>/<extension_name>.xpi``
* ``salt://tool_firefox/addons/default/<extension_name>.xpi``

Execution and state module
~~~~~~~~~~~~~~~~~~~~~~~~~~
At some point, I want to write those to be able to manage Firefox easier and possibly without enterprise policies. They are mostly auto-generated at the moment, so just skip over them.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_firefox`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_firefox:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_firefox/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Sync this user's config from a dotfiles repo.
      # The available paths and their priority can be found in the
      # rendered `config/sync.sls` file (currently, @TODO docs).
      # Overview in descending priority:
      # salt://dotconfig/<minion_id>/<user>/
      # salt://dotconfig/<minion_id>/
      # salt://dotconfig/<os_family>/<user>/
      # salt://dotconfig/<os_family>/
      # salt://dotconfig/default/<user>/
      # salt://dotconfig/default/
    dotconfig:              # can be bool or mapping
      file_mode: '0600'     # default: keep destination or salt umask (new)
      dir_mode: '0700'      # default: 0700
      clean: false          # delete files in target. default: false

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_firefox:users`.
      # Set this to `false` to disable configuration for this user.
    firefox:
        # If arkenfox is selected as userjs, this customizes the installation.
      arkenfox:
          # Run cleanPrefs after each upgrade.
          # This will need to stop Firefox when run.
        autoclean_prefs: true
          # Activate common overrides automatically.
        override:
            # Use the URL bar to search with the default search engine as well.
          autosearch: false
            # Enable DRM.
          drm: false
            # Save form data and enable autofill.
          form_autofill: false
            # Keep history.
          history_keep: false
            # When RFP is enabled, disable letterboxing.
          letterboxing_disabled: false
            # Reset referrer privacy to default (always send).
          referrer_always: false
            # Disable RFP (resist fingerprint).
            # https://github.com/arkenfox/user.js/wiki/3.3-Overrides-%5BTo-RFP-or-Not%5D
            # If this is true, leaving WebGL disabled does not provide much benefit.
          rfp_disabled: false
            # Safe Browsing: Enable remote lookups of downloads.
          safe_browsing_download_remote_lookup: false
            # Restore sessions on startup. Disables history clearing on close.
          session_restore: false
            # Disable strict certificate pinning.
          strict_pinning_disabled: false
            # Enable WebGL.
          webgl: false
          # Specify custom overrides as name: value mapping.
          # The value will be JSON-encoded.
        override_custom:
          some.other.firefox.pref: value
        # You can specify a direct download of a default `user.js`
        # for your default profile (atm) or use arkenfox user.js.
        # For the latter, just set it to the string "arkenfox".
        # For the former, this can be just the url as a string
        # (no hash check -> unsafe) or a mapping of hash and source like this:
      userjs:
        hash: a395ed35ea2bfbaf8c3f99383df46ec4f358d6e8cac3a9638d896ce8f210bd71
        source: https://raw.githubusercontent.com/arkenfox/user.js/master/user.js

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_firefox:

      # Which Firefox version to install:
      # esr, stable, dev, nightly, beta
    version: esr

    extensions:
        # List of extensions that should not be installed.
      absent:
        - tampermonkey

        # Defaults for extension installation settings
      defaults:
        installation_mode: normal_installed
        updates_disabled: false

      local:
          # When marking extensions as local, use this path on the minion to look for <extension>.xpi by default.
        source: /opt/firefox_addons
          # When using local source, sync extensions automatically from the fileserver.
          # You will need to provide the extensions as
          # `tool_firefox/addons/<tofs_grain>/<extension>.xpi`
        sync: true

        # List of extensions that are to be installed. When using policies, can also be specified there
        # manually, but this provides convenience. See `tool_firefox/parameters/defaults.yaml` for a list of
        # available extensions under `lookup:extension_data`. Of course, you can also specify your own on top.
      wanted:
        - bitwarden
          # If you want to override defaults, you can specify them
          # in a mapping like this:
        - ublock-origin:
            installation_mode: force_installed
          # If you don't want an extension to be loaded from the Mozilla Addon Store,
          # but rather from a local directory specified in extensions:defaults:local_source,
          # set local to true and make sure to provide e.g. metamask.xpi in there:
        - metamask:
            local: true

      # This is where you specify enterprise policies.
      # See https://github.com/mozilla/policy-templates for available settings.
    policies:
      DisableTelemetry: true
      NoDefaultBookmarks: true
      OverrideFirstRunPage: about:blank
      OverridePostUpdatePage: about:blank

      # Default formula configuration for all users.
    defaults:
      userjs: default value for all users

Dotfiles
~~~~~~~~
``tool_firefox.config.sync`` will recursively apply templates from

* ``salt://dotconfig/<minion_id>/<user>/``
* ``salt://dotconfig/<minion_id>/``
* ``salt://dotconfig/<os_family>/<user>/``
* ``salt://dotconfig/<os_family>/``
* ``salt://dotconfig/default/<user>/``
* ``salt://dotconfig/default/``

to the user's config dir for every user that has it enabled (see ``user.dotconfig``). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

The URL list above is in descending priority. This means user-specific configuration from wider scopes will be overridden by more system-specific general configuration.


Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_firefox``
~~~~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_firefox.package``
~~~~~~~~~~~~~~~~~~~~~~~~
Installs the Mozilla Firefox package only.


``tool_firefox.package.choco``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.package.pkg``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.package.tar``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.config``
~~~~~~~~~~~~~~~~~~~~~~~
Manages the Mozilla Firefox package configuration by

* recursively syncing from a dotfiles repo

Has a dependency on `tool_firefox.package`_.


``tool_firefox.local_addons``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.policies``
~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.policies.winadm``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.userjs``
~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.userjs.arkenfox``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.default_profile``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.clean``
~~~~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_firefox`` meta-state
in reverse order.


``tool_firefox.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Mozilla Firefox package.
Has a dependency on `tool_firefox.config.clean`_.


``tool_firefox.package.choco.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.package.pkg.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.package.tar.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the configuration of the Mozilla Firefox package.


``tool_firefox.local_addons.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.policies.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.policies.winadm.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.userjs.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_firefox.userjs.arkenfox.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Todo
----
* allow per-user installation generally (for linux with tar/snap/...)
* implement firefox execution/state module with ``mozprofile`` to manage individual profiles
* then make it possible to specify settings per profile
* userjs implementation makes only some sense. better make it per-user

Reference
---------
* https://support.mozilla.org/en-US/products/firefox-enterprise/policies-customization-enterprise/policies-overview-enterprise
* https://github.com/mozilla/policy-templates
* https://wiki.mozilla.org/Firefox/CommandLineOptions
* https://www.userchrome.org/what-is-userchrome-js.html
