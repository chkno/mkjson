Create a JSON object from keys & values from the command line.
End a key with `@` to indicate that the following argument is a filename from which to read the value.

    $ mkjson key value now "$(date)" hostname@ /etc/hostname
    {"key": "value", "now": "Thu 03 Dec 2020 02:15:00 PM PST", "hostname": "gibson\n"}
