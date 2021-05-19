Create a JSON object from keys & values from the command line.

End a key with `@` to indicate that the following argument is a filename from which to read the value.

End a key with `!` to indicate that the following argument is JSON.  It will be parsed and re-emitted as a normal JSON value within the output document rather than emitted as a much-quoted string.

(`@!` and `!@` are both acceptable to trigger both forms of special processing, but prefer `@!` to avoid [history shell expansion](https://www.gnu.org/software/bash/manual/bash.html#History-Interaction).)

    $ mkjson key value now "$(date)" hostname@ /etc/hostname
    {"key": "value", "now": "Thu 03 Dec 2020 02:15:00 PM PST", "hostname": "gibson\n"}

    $ mkjson registry@! /etc/nix/registry.json
    {"registry": {"flakes": [], "version": 2}}
