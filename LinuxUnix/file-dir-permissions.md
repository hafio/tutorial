# Key information
| Permission | File / Directory | Description |
| - | - | - |
| `read` | File | Open file content
| `read` | Directory | List files in directory |
| `write` | File | Change file content |
| `write` | Directory | Create, move, rename, and delete files in the directory<br>(Directory execute permissions required) |
| `execute` | File | Execute (script/binary) files<br>(Directory execute permission required) |
| `execute` | Directory | Look at extended information of files in directory and change directory |

# Linux Permission format examples
| Directory flag | Owner | Group | Others | Description |
| - | - | - | - | - | 
| `d` | `rwx` | `rwx` | `rwx` | Everyone has access to directory and its content |
| `d` | `rwx` | `rwx` | `---` | Only owner and group have access to directory |
| | `rwx` | `rwx` | `rwx` | Everyone has access to the file |

# Special Permissions
| Directory flag | Owner | Group | Others | Description |
| - | - | - | - | - | 
| | `---s` | | | Set UID: Allows file to be executed as owner instead of executor |
| | | `---s` | | Set GID: <li>Allows file to be executed as owner group instead of executor group<br><li>Also used for inherit file group permissions in directory |
| | | | `---t` | Sticky: Restricts files to be renamed/deleted within directory to owner only |