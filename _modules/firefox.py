"""
firefox execution module (UNFINISHED, this is mostly auto-generated)
======================================================

"""
from salt.exceptions import CommandExecutionError
# import logging
import salt.utils.platform

try:
    HAS_MOZPROFILE = True
    import mozprofile
except ImportError:
    HAS_MOZPROFILE = False

# log = logging.getLogger(__name__)
__virtualname__ = "firefox"


def __virtual__():
    return __virtualname__


def _which(user=None):
    if e := salt["cmd.run"]("command -v firefox", runas=user):
        return e
    if salt.utils.platform.is_darwin():
        if p := salt["cmd.run"]("brew --prefix firefox", runas=user):
            return p
        for f in ['/opt/homebrew/bin', '/usr/local/bin']:
            if p := salt["cmd.run"]("test -s {}/code && echo {}/code".format(f, f) , runas=user):
                return p
    raise CommandExecutionError("Could not find firefox executable.")


def is_installed(name, user=None):
    return name in _list_installed(user)


def install(name, user=None):
    e = _which(user)

    return __salt__['cmd.retcode']("{} install '{}'".format(e, name), runas=user)


def remove(name, user=None):
    e = _which(user)

    return __salt__['cmd.retcode']("{} uninstall '{}'".format(e, name), runas=user)


def upgrade(name, user=None):
    e = _which(user)

    return __salt__['cmd.retcode']("{} upgrade '{}'".format(e, name), runas=user)


def _list_installed(user=None):
    e = _which(user)
    out = json.loads(__salt__['cmd.run']('{} list'.format(e), runas=user, raise_err=True))
    if out:
        return _parse(out)
    raise CommandExecutionError('Something went wrong while calling firefox.')


def _parse(installed):
    pass
