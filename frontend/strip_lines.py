import sys
import re

content = sys.stdin.read()
# Regex to match line numbers like "1: ", "10: ", etc. at the start of lines
# We need to be careful with multi-line strings that might have similar patterns
# But view_file always starts each line with "<number>: "
lines = content.splitlines()
result = []
for line in lines:
    match = re.match(r'^\d+:\s?(.*)', line)
    if match:
        result.append(match.group(1))
    else:
        result.append(line)

print('\n'.join(result))
