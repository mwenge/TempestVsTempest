import sys
import os
import re
"""
Reformat source code lines in a file such as yak.s so that the
comments are uniformly aligned.
"""
lines = sys.stdin.readlines()
code_lines = [l.split(';')[0].rstrip() for l in lines]
comm_lines = ["; "+l.split(';')[1].strip() if ";" in l else ""  for l in lines]

MAX_COMMENT_START = 32 
for i,l in enumerate(code_lines):
  # If the whole line is a comment, just print as is.
  if lines[i].lstrip().startswith(';'):
    print(lines[i].rstrip())
    continue

  max_code_len = max(len(l), MAX_COMMENT_START) - len(l)
  comment = (" " * max_code_len) + (" " * 3) + comm_lines[i] if comm_lines[i] else ""
  if l.strip():
      print(l + comment)
  else:
      print((" " * 4) + comm_lines[i])




# vim:ts=2
