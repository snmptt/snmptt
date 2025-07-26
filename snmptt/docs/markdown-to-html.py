#!/usr/bin/env python3
# sudo pip3 install markdown

import markdown
import sys
import os

def split_html_markdown(content, marker='<!-- END_HTML -->'):
    """
    Split content into HTML and Markdown parts using a marker.
    """
    split_marker = f'\n{marker}\n'
    if split_marker in content:
        html_part, markdown_part = content.split(split_marker, 1)
        return html_part.strip(), markdown_part.strip()
    else:
        raise ValueError(f"Marker '{marker}' not found in the file.")

def process_markdown_file(input_path):
    try:
        # Check file existence
        if not os.path.isfile(input_path):
            raise FileNotFoundError(f"File not found: {input_path}")

        # Read file
        with open(input_path, 'r', encoding='utf-8') as f:
            raw_content = f.read()

        # Split into HTML and Markdown
        html_section, markdown_section = split_html_markdown(raw_content)

        # Convert Markdown to HTML
        try:
            markdown_html = markdown.markdown(
                markdown_section,
                extensions=['markdown.extensions.tables'])
        except Exception as e:
            raise RuntimeError(f"Error converting markdown: {e}")

        # Output combined HTML to stdout
        final_output = html_section + '\n\n' + markdown_html
        print(final_output)

    except FileNotFoundError as fnf_err:
        print(f"❌ File error: {fnf_err}", file=sys.stderr)
        sys.exit(1)
    except ValueError as val_err:
        print(f"❌ Format error: {val_err}", file=sys.stderr)
        sys.exit(2)
    except RuntimeError as rt_err:
        print(f"❌ Processing error: {rt_err}", file=sys.stderr)
        sys.exit(3)
    except Exception as e:
        print(f"❌ Unexpected error: {e}", file=sys.stderr)
        sys.exit(99)

# Entry point
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 process_md.py <input_file.md>", file=sys.stderr)
        sys.exit(1)

    input_file = sys.argv[1]
    process_markdown_file(input_file)
