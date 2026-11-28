# Languages

> Applies to RePruning **v0.0.6**.

Every message the plugin sends — the MOTD fix guide, the kick reasons, the startup info — is
loaded from language files. The language is selected with the `pruning_lang` cvar:

```
pruning_lang "us"
```

The files live in `addons/amxmodx/data/repruning/<code>/repruning.txt` — one folder per
language:

| Code | Language | Code | Language |
| :--- | :------- | :--- | :------- |
| `us` | English | `ru` | Russian |
| `ua` | Ukrainian | `kz` | Kazakh |
| `de` | German | `pl` | Polish |
| `dk` | Danish | `se` | Swedish |
| `fr` | French | | |

Every file uses the same format — one `KEY = text` pair per line:

```
MOTD_HEAD = File failed the check: %s
KICK_BAN = file mismatch, banned %d min: %s
```

If a key is missing in the selected language, the plugin falls back to the English (`us`) file,
and if it is missing there as well, the key name itself is printed. To add your own language,
create a folder with the language code, copy the English file into it and translate the values.
