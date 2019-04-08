# Copyright (c) 2017 Yandex LLC. All rights reserved.
# Author: Kirill Kosarev <kirr@yandex-team.ru>

import json
import sys

import yin.teamcity.theserver as theserver
from yin.perf.base.sample_tests import iqr

with open(sys.argv[1]) as f:
    json_data = json.load(f)

teamcity = theserver.teamcity_desktop_server()
results = {}
for b in json_data:
    build_id = b['_id']
    data = teamcity.download_artifact(build_id, 'results.json')
    measurements = json.loads(data)['measurements']
    values = []
    for m in measurements:
        rbs = m['results_by_selector']
        if rbs:
            values.append(rbs[0]['values'])

    params =  teamcity.build_details(build_id).properties['extra_args'].split()
    magnitude_index = params.index('--anomaly-magnitude')
    magnitude = float(params[magnitude_index+1])

    magnitudes = []
    for v in values:
        iqr_value = iqr(v)
        magnitude = (abs(magnitude / iqr_value) if iqr_value else 1000)
        magnitudes.append(magnitude)
    results[build_id] = [x for x in magnitudes if x >= 1.0 and x <= 2.0]

print json.dumps(results, indent=2)
