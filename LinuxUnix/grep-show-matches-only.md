This guide covers the logic and the command for extracting specific log segments—timestamp, event type, and reason—while ensuring the output is clean and non-greedy.

---

## Log Extraction Guide: Multi-Part Pattern Matching

### 1. The Core Command
Use this command to extract the **Timestamp**, the **Event**, and the **First Reason** from your log files.

```bash
grep -Po '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}\+08:00|CLIENT_CLIENT_DISCONNECT|reason\([^)]*\)' filename.log
```

### 2. Breakdown of the Regex Patterns
The command uses the `|` (OR) operator to find three distinct patterns on the same line:

* **Timestamp:** `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}\+08:00`
    * Matches the ISO8601 format at the start of the line (`^`).
* **Event:** `CLIENT_CLIENT_DISCONNECT`
    * Matches the literal string for the specific event you are tracking.
* **Reason (Non-Greedy):** `reason\([^)]*\)`
    * `reason\(`: Matches the start of the reason block.
    * `[^)]*`: Matches every character **except** a closing parenthesis. This ensures it stops at the very first `)` it sees.
    * `\)`: Matches the closing parenthesis.

### 3. Display Options

#### Option A: Vertical List (Default)
Useful for quick terminal viewing. Each match appears on its own line.
```bash
grep -Po '...' file.log
```

#### Option B: Single Line (Tab or Space Separated)
Useful for creating a clean list where one log entry equals one line of output.
```bash
grep -Po '...' file.log | paste -d " " - - -
```

#### Option C: CSV Format
Useful if you want to import the results into Excel or Google Sheets.
```bash
grep -Po '...' file.log | paste -d "," - - - > results.csv
```

### 4. Troubleshooting
* **No Output?** Ensure your `grep` version supports `-P` (Perl-regex). Most Linux distributions (GNU grep) do. If you are on macOS, you may need to install `ggrep` via Homebrew.
* **Extra Parentheses:** If the "reason" contains nested parentheses like `reason(error(10))`, the command will stop at the first `)`. To capture nested groups, you would typically need a more complex tool like `sed` or `awk`.

---
