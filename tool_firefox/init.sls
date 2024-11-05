# vim: ft=sls

{#-
    *Meta-state*.

    Performs all operations described in this formula according to the specified configuration.
#}

include:
  - .package
  - .config
  - .local_addons
  - .policies
  - .userjs
