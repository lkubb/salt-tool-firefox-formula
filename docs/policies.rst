.. _policies.example:

Example Policies
================

.. code-block:: yaml

    AppUpdate: true
    Cookies:
      AcceptThirdParty: never
      Allow: []
      AllowSession: []
      Block: []
      Default: true
      ExpireAtSessionEnd: true
      Locked: false
      RejectTracker: true
    DisableFirefoxStudies: true
    DisablePocket: true
    DisableProfileImport: true
    DisableProfileRefresh: true
    DisableTelemetry: true
    EnableTrackingProtection:
      Cryptomining: true
      Exceptions: []
      Fingerprinting: true
      Locked: false
      Value: true
    ExtensionSettings:
      '*':
        allowed_types:
          - extension
          - theme
          - dictionary
          - locale
        blocked_install_message: Installation blocked by policies.json.
        installation_mode: normal_installed
          # Content scripts cannot run on those domains.
        restricted_domains: []
    ExtensionUpdate: false
    FirefoxHome:
      Highlights: false
      Locked: false
      Pocket: false
      Search: true
      Snippets: false
      TopSites: true
    FlashPlugin:
      Allow: []
      Block: []
      Default: false
      Locked: true
    Homepage:
      Additional: []
      Locked: false
      StartPage: homepage
      URL: 'about:blank'
    NewTabPage: true
    NoDefaultBookmarks: true
    OverrideFirstRunPage: 'about:blank'
    OverridePostUpdatePage: 'about:blank'
    Permissions:
      Autoplay:
        Allow: []
        Block: []
        Default: block-audio-video
        Locked: false
      Camera:
        Allow: []
        Block: []
        BlockNewRequests: false
        Locked: false
      Location:
        Allow: []
        Block: []
        BlockNewRequests: false
        Locked: false
      Microphone:
        Allow: []
        Block: []
        BlockNewRequests: false
        Locked: false
      Notifications:
        Allow: []
        Block: []
        BlockNewRequests: false
        Locked: false
    PopupBlocking:
      Allow: []
      Default: true
      Locked: false
    SearchBar: unified
      # Only available on ESR!
    SearchEngines:
      Default: DuckDuckGo
      Remove: []
    SearchSuggestEnabled: true
    UserMessaging:
      ExtensionRecommendations: false
      FeatureRecommendations: false
      SkipOnboarding: true
      UrlbarInterventions: false
      WhatsNew: false
