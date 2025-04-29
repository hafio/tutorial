# Custom DNS block list

This is a consolidated list of DNS names taken from:
- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
- https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
- https://phishing.army/download/phishing_army_blocklist.txt
- https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt

# How to use

Add this to Pi-hole Lists

# How to update/re-generate

1. Use Excel file, update list of DNS names in 'dns' table under 'names' tab.
    a. Use Excel 'Remove Duplicate' function to remove duplicate domain names.
2. Export 'blocklist' tab as text file
3. Run `clean.sh` to convert the file to unix, and remove empty lines.
