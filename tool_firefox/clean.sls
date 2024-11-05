# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_firefox`` meta-state
    in reverse order.
#}

include:
  - .policies.clean
  - .config.clean
  - .local_addons.clean
  - .package.clean
