UUID
====

A simple library for generating/using Universally Unique Identifiers, as defined
in RFC 4122 (http://www.ietf.org/rfc/rfc4122.txt).

This library generates version 4 UUIDs, which are based on random bytes (read
from a platform-specific source -- /dev/urandom or /dev/random on *NIX systems,
and CryptGenRandom on Windows). All other Ruby UUID libraries I looked at either
used the much more complex version 1 generation algorithm (using MAC address and
unique timestamp), or used random bytes, but didn't properly set the version and
reserved flags.

Author
------

Gabriel Boyer (gboyer@gmail.com)
