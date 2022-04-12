"""
firefox salt states (UNFINISHED, this is mostly auto-generated)
======================================================

"""

# import logging
import salt.exceptions

# import salt.utils.platform

# log = logging.getLogger(__name__)

__virtualname__ = "firefox"


def __virtual__():
    return __virtualname__


def installed(name, user=None):
    """
    Make sure program is installed with firefox.

    CLI Example:

    .. code-block:: bash

        salt '*' firefox.installed example user=user

    name
        The name of the program to install, if not installed already.

    user
        The username to install the program for. Defaults to salt user.

    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if __salt__["firefox.is_installed"](name, user):
            ret["comment"] = "Program is already installed with firefox."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' would have been installed for user '{}'.".format(
                name, user
            )
            ret["changes"] = {"installed": name}
        elif __salt__["firefox.install"](name, user):
            ret["comment"] = "Program '{}' was installed for user '{}'.".format(
                name, user
            )
            ret["changes"] = {"installed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling firefox."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret


def uptodate(name, user=None):
    """
    Make sure program is installed with firefox and is up to date.

    CLI Example:

    .. code-block:: bash

        salt '*' firefox.uptodate example user=user

    name
        The name of the program to upgrade or install.

    user
        The username to install the program for. Defaults to salt user.

    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if __salt__["firefox.is_installed"](name, user):
            if __opts__["test"]:
                ret["result"] = None
                ret[
                    "comment"
                ] = "App '{}' would have been upgraded for user '{}'.".format(
                    name, user
                )
                ret["changes"] = {"installed": name}
            elif __salt__["firefox.upgrade"](name, user):
                ret["comment"] = "Program '{}' was upgraded for user '{}'.".format(
                    name, user
                )
                ret["changes"] = {"upgraded": name}
            else:
                ret["result"] = False
                ret["comment"] = "Something went wrong while calling mas."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' would have been installed for user '{}'.".format(
                name, user
            )
            ret["changes"] = {"installed": name}
        elif __salt__["firefox.install"](name, user):
            ret["comment"] = "Program '{}' was installed for user '{}'.".format(
                name, user
            )
            ret["changes"] = {"installed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling firefox."
        return ret

    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret


def absent(name, user=None):
    """
    Make sure firefox installation of program is removed.

    CLI Example:

    .. code-block:: bash

        salt '*' firefox.absent example user=user

    name
        The name of the program to remove, if installed.

    user
        The username to remove the program for. Defaults to salt user.

    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if not __salt__["firefox.is_installed"](name, user):
            ret["comment"] = "Program is already absent from firefox."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' would have been removed for user '{}'.".format(name, user)
            ret["changes"] = {"removed": name}
        elif __salt__["firefox.remove"](name, user):
            ret["comment"] = "Program '{}' was removed for user '{}'.".format(
                name, user
            )
            ret["changes"] = {"removed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling firefox."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret
