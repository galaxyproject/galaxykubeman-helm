#!/usr/bin/env python
import json
import os
import yaml

PATCH_LABELS = ["patch", "fix", "bug", "docs"]
MINOR_LABELS = ["minor", "feature"]
MAJOR_LABELS = ["major", "release"]

chartName = os.getenv('CHART_NAME')

with open(chartName + "/Chart.yaml", 'r') as chart:
    d = yaml.safe_load(chart)

bump = None
labels = [l.get("name")
          for l in json.loads(os.environ['GITHUB_CONTEXT'])['event']
          ['pull_request'].get('labels', [])]

if len([value for value in PATCH_LABELS if value in labels]) > 0:
    bump = "patch"
elif len([value for value in MINOR_LABELS if value in labels]) > 0:
    bump = "minor"
elif len([value for value in MAJOR_LABELS if value in labels]) > 0:
    bump = "major"

if bump:
    print(" ".join([d['version'], bump]))
else:
    print("nobump")
