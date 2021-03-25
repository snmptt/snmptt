#!/usr/bin/python3
import sys
import markdown

# sudo pip3 install markdown

with open(sys.argv[1], 'r') as f:
    text = f.read()
    html = markdown.markdown(text,extensions=['tables'])
    
print(html)
