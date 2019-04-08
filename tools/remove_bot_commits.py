import sys

from yin.issue_trackers.startrek import theclient

st_client = theclient()
ticket = sys.argv[1]

issue = st_client.issues[ticket]
for c in issue.comments:
    should_remove = (c.text.startswith('Anomalies at the same revision') or
                     c.text.startswith('Triggered bisect'))
    if should_remove:
        c.delete()
