import json
import sys

import numpy

from dashboard.find_change_points import FindChangePoints


with open(sys.argv[1]) as f:
    data = json.load(f)

series = map(lambda x: (x['_id'], numpy.mean(x['value'])), data)
info_by_commit = [(x['_id'], x['commit'], numpy.mean(x['value']), x['build_timestamp']) for x in data]

print '\n'.join([str(x) for x in info_by_commit])
last_anomaly = None
for i in xrange(1, len(series)):
    current_points = series[:i]
    anomaly_index = next(
        (i for i, x in enumerate(current_points) if x[0] == last_anomaly), None)
    if anomaly_index:
        current_points = current_points[anomaly_index:]
    for point in FindChangePoints(current_points, max_window_size=40):
        print point
        last_anomaly = point.x_value
