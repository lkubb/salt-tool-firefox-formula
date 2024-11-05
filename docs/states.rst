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



