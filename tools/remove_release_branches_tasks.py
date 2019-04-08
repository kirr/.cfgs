import sys

from yin.issue_trackers.startrek import theclient

st_client = theclient()

query = 'Queue: BROWSERAN AND Tags: "kind:anomaly"'
issues = st_client.issues.find(query)
for i in issues:
    comments = i['comments']
    count = len([c for c in comments])
    if count > 2:
        print i.key

