#!/usr/bin/env python3
"""parser.py

Parses a Word .docx in the standard Microsoft "What to say / What to show" two-column table
and emits a YAML demo-definition file using the lightweight schema.

Usage:
  python parser.py input.docx -o demo.yaml

Dependencies:
  pip install python-docx pyyaml

This parser is intentionally minimal: it finds the first two-column table where the left column
is 'What to say' and the right is 'What to show' (case-insensitive). Each table row becomes a scene.

"""
import sys
import argparse
from docx import Document
import yaml
import re


def normalize_header(s):
    return re.sub(r"\s+", " ", s.strip().lower())


def parse_docx_two_column(path):
    doc = Document(path)
    # Find first table with 2 columns and suspected headers
    for table in doc.tables:
        if len(table.columns) < 2:
            continue
        # inspect header row text
        first_row = table.rows[0]
        left = first_row.cells[0].text.strip()
        right = first_row.cells[1].text.strip()
        if normalize_header(left).startswith("what to say") or normalize_header(left).startswith("what i say"):
            # accept this table
            scenes = []
            # Skip header row; parse following rows
            for r in table.rows[1:]:
                left_txt = r.cells[0].text.strip()
                right_txt = r.cells[1].text.strip()
                if not left_txt and not right_txt:
                    continue
                # Try to split left text into header + numbered steps if present
                # Heuristic: bolded header in Word may not be accessible via text; use a line with all-caps or ends with ':'
                lines = [ln.strip() for ln in left_txt.splitlines() if ln.strip()]
                header = None
                narration = None
                beats = []
                if lines:
                    # If first line ends with ':' or is short, treat as header
                    if len(lines[0]) < 60 and (lines[0].endswith(':') or lines[0].istitle()):
                        header = lines[0].rstrip(':')
                        narration = '\n'.join(lines[1:]) if len(lines) > 1 else ''
                    else:
                        narration = '\n'.join(lines)
                # Extract numbered beats from narration (lines starting with 1., 2., - )
                beat_lines = []
                new_narration_lines = []
                for ln in (narration or '').splitlines():
                    if re.match(r"^\s*\d+[\.)]", ln) or re.match(r"^\s*[-\u2022]\s+", ln):
                        beat_lines.append(ln.strip())
                    else:
                        new_narration_lines.append(ln)
                narration = '\n'.join(new_narration_lines).strip()
                # Convert beat lines to beat objects with naive parse: "1. Click X on Y"
                for bl in beat_lines:
                    # remove numbering
                    b = re.sub(r'^\s*\d+[\.)]\s*', '', bl)
                    b = re.sub(r'^\s*[-\u2022]\s*', '', b)
                    # Split into action / target by ' on ' or ' -> '
                    if ' on ' in b:
                        action, target = b.split(' on ', 1)
                    elif ' -> ' in b:
                        action, target = b.split(' -> ', 1)
                    else:
                        action, target = b, ''
                    beats.append({'action': action.strip(), 'target_selector': target.strip()})
                # Right cell becomes surface hint
                surface = right_txt.splitlines()[0].strip() if right_txt else ''
                scene = {
                    'id': re.sub(r'[^a-z0-9]+','-', (header or surface or 'scene')).strip('-').lower()[:40] + '-' + str(len(scenes)+1),
                    'type': 'beat',
                    'approx_duration_s': 60,
                    'surface_url': surface,
                    'narration': narration or '',
                    'beats': beats,
                    'presenter_notes': '',
                    'persona': {'name': None, 'avatar_path': None}
                }
                # If header present and looks like a section separator, mark first scene of a block as 'open'
                if header and len(scenes)==0:
                    scene['type'] = 'open'
                scenes.append(scene)
            return {'title': '', 'audience': '', 'scenes': scenes}
    # fallback: no table found
    raise ValueError('No two-column "What to say / What to show" table found in the document')


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('docx', help='.docx file path')
    ap.add_argument('-o', '--output', help='Output YAML path', required=True)
    args = ap.parse_args()
    try:
        demo = parse_docx_two_column(args.docx)
    except Exception as e:
        print('Error parsing:', e)
        sys.exit(2)
    # Add a minimal title placeholder if none
    if not demo.get('title'):
        demo['title'] = 'Demo generated from docx'
    with open(args.output, 'w', encoding='utf-8') as f:
        yaml.safe_dump(demo, f, sort_keys=False, allow_unicode=True)
    print('Wrote', args.output)
