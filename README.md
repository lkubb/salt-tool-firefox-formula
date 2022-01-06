# Mozilla Firefox Formula
Sets up and configures Mozilla Firefox browser.

## Usage
Applying `tool-firefox` will make sure Mozilla Firefox is configured as specified. This is achieved mostly by Group Policies.

Note: In the current state, this formula needs to run twice to finish configuration if you chose to sync files to your profile (eiter user.js specifically or dotconfig). Once to install Firefox and generate the default profile, then once more to actually copy the files. This is caused by technical limitations in SaltStack (Jinja renders before states are run, therefore – on the first run on a virgin system – Firefox does not exist to it.)

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-firefox` pillar configuration. Namespace it to `tool:users` and/or `tool:firefox:users`.
```yaml
user:
  dotconfig: true                   # sync this user's config from a dotfiles repo available as salt://dotconfig/<user>/firefox or salt://dotconfig/firefox
  firefox:
    userjs: true                    # sync userjs from formula-defined source for this user
```

#### Formula-specific
```yaml
tool:
  firefox:
    version: esr                        # esr, stable, dev, nightly, beta. defaults to esr
    # When using policies.json on Linux, there is only one global policy file, therefore these
    # settings have to be global there. User-specific settings with policies are possible on MacOS
    # afaik where policies are installed via a profile.
    #################################################################################################
    ext_default_installmode: normal_installed # when not specified, use this extension installation mode by default
    ext_default_updatedisabled: false # when not specified, use this value for extension update settings
    ext_local_source: /some/path # when marking extensions as local, use this path to look for extension.xpi by default
    ext_local_source_sync: true  # when using local source, sync extensions from salt://tool-firefox/files/addons
    # List of extensions that are to be installed. When using policies, can also be specified there
    # manually, but this provides convenience. see tool-firefox/config/policies/addons for list of
    # available extensions
    extensions:
      - bitwarden
      # if you don't want the default extension settings for your policy, you can specify them
      # in a mapping like this:
      - ublock-origin:
          installation_mode: force_installed
      # If you don't want an extension to be loaded from the Mozilla Addon Store,
      # but rather from a local directory specified in tool:firefox:local_extension,
      # set local to true and make sure to provide e.g. metamask.xpi in there:
      - metamask:
          local: true
    policies:
      DisableTelemetry: true
      NoDefaultBookmarks: true
      OverrideFirstRunPage: 'about:blank'
      OverridePostUpdatePage: 'about:blank'
    # You can specify a direct download of a default user.js for your default profile (atm).
    # By default, the source hash will not be checked (unsafe).
    userjs: https://raw.githubusercontent.com/arkenfox/user.js/master/user.js
    # You can specify the expected hash in a mapping like this:
   #userjs:
   #  source: https://raw.githubusercontent.com/arkenfox/user.js/master/user.js
   #  hash: a395ed35ea2bfbaf8c3f99383df46ec4f358d6e8cac3a9638d896ce8f210bd71
    # Windows-specific settings when using policies, defaults as seen below
    # To be able to use Group Policies, this formula needs to ensure the templates are available. (really?)
    # See https://github.com/mozilla/policy-templates to find which version you need
    # depending on the Firefox version you are installing. Default hashes are available
    # up to version 3.4 and only for en_US.
    win_gpo_owner: Administrators
    win_gpo_policy_dir: C:\Windows\PolicyDefinitions
    win_gpo_policy_revision: '3.4' # if you change this to a version greater than this, you need to specify hashes yourself
    win_gpo_lang: en_US # if you change this, you need to specify hashes yourself
    win_gpo_hashes:
      firefox:
        adml: 38f3fe9b417e32204ccca3697eca9210038d5c4f67c4a41bc2b69f363ba9a94b
        admx: 3a54c35de8ce6873e3318564ae2c6d9051d44dd330b0d7490fb7c5219570e83c
      mozilla:
        adml: cd802549112e61044ba648d05db8b0edc446a3458d18333748b83c0fa49c9894
        admx: 63872a03337f0268085c43c45f1ef05cd2ce68e36bb54c63f0cd128985c76bb0
    defaults: # default values for user configurations
      userjs: true
```

### Dotfiles
Firefox does not make a good fit with dotfiles sadly. If a user has `dotconfig` enabled, this formula will sync files from

- `salt://dotconfig/<user>/firefox` or
- `salt://dotconfig/firefox`

to your default profile. This works in the first run **after Firefox has been installed**.

## Todo
- implement firefox execution/state module with mozprofile to manage individual profiles
- then make it possible to specify settings per profile
- userjs implementation makes only some sense. better make it per-user
