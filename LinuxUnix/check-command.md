Execute to check if command exist:

```bash
command -v <command>
```

For Bash Conditions:

```bash
if command -v <command> > /dev/null 2>&1 ; then
  # do something if command exists
fi

if ! command -v <command> > /dev/null 2>&1 ; then
  # do something if command doesn't exist
fi
```
