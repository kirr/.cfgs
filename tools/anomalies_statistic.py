
# Copyright (c) 2017 Yandex LLC. All rights reserved.import argparse
# Author: Kirill Kosarev <kirr@yandex-team.ru>

import argparse
from collections import defaultdict, namedtuple
import datetime
import logging
import re
import urlparse

from yin.perf.anomalies import tasks
from yin.perf.anomalies import utils
import yin.perf.base.important_selectors as important_selectors
import yin.perf.dashboard.client as dashboard

DEFAULT_RANGE = datetime.timedelta(days=14)
Key = namedtuple('Key', ['benchmark', 'commit', 'detect_date', 'branch'])

def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--important-selectors-config',
                        default=important_selectors.IMPORTANT_SELECTORS_FILE)
    parser.add_argument('--frontend-url', required=True)
    parser.add_argument(
        '--since', type=utils.valid_date,
        help='Format YYYY-MM-DD',
        default=(datetime.datetime.utcnow() - DEFAULT_RANGE))
    parser.add_argument(
        '--till', type=utils.valid_date,
        help='Format YYYY-MM-DD',
        default=datetime.datetime.utcnow())
    return parser.parse_args()

def main(args):
    logging.basicConfig(level=logging.INFO, format='%(message)s')

    perf_client = dashboard.PerfDashboardClient(args.frontend_url)

    anomalies = perf_client.get_anomalies(args.since, args.till)
    anomalies = tasks.filter_anomalies(args.important_selectors_config, anomalies)
    groups = defaultdict(list)
    for a in anomalies:
        date = datetime.datetime.utcfromtimestamp(a.detect_timestamp).date()

        key = Key(a.benchmark, a.commit, date, a.branch)
        groups[key].append(a.selector.encode('utf-8'))
    for k, v in groups.iteritems():
        print k, '\n', '\n'.join(v)
    print len(groups)


if __name__ == '__main__':
    args = _parse_args()
    main(args)
