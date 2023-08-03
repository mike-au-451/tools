# tools
## Misc tools, mostly historical interest.

Tools that attempt to modify the current environment work through aliases,
which are loaded from entries when a terminal is started.  Include something
like the following in .bashrc:

```
for ff in $HOME/lib/*.sh
do
        source $ff
done
```
