import base64
import logging
import urllib2
import xml.etree.ElementTree as et
import re
from collections import defaultdict


LOGIN = 'teamcity'
PASSWORD = 'Cleph8OvOwd'
ARTIFACTS_URL_TEMPLATE = (
    'https://teamcity.browser.yandex-team.ru/repository/download/'
    'Browser_Tests_UnitTestsWinGn/{0}:id/tests_results_win.zip%21/{1}/{1}.log')
BUILDS_URL = (
    'https://teamcity.browser.yandex-team.ru/app/rest/10.0/builds/?'
    'locator=branch:master,buildType:Browser_Tests_UnitTestsWinGn,'
    'count:1000&fields=build(id)')

START_RE = re.compile('^\[\d+/\d+\] ([\w\.]+) (\w+)')

def get_content(url):
    build_request = urllib2.Request(url)
    build_request.add_unredirected_header(
        'Authorization',
        'Basic ' + base64.b64encode('{0}:{1}'.format(LOGIN, PASSWORD)))
    response = urllib2.urlopen(build_request)
    return response.read()

def get_retried_tests(build_id):
    content = get_content(ARTIFACTS_URL_TEMPLATE.format(
        build_id, 'browser_telemetry_perf_unittests'))
    lines = content.splitlines()
    start_index = next((i for i, l in enumerate(lines) if l == 'Retrying failed tests (attempt #1 of 3)...'), -1)
    end_index = next((i for i, l in enumerate(lines) if l == 'Retrying failed tests (attempt #2 of 3)...'), len(lines))
    if start_index == -1:
        return []

    res = []
    for l in lines[start_index+1:end_index]:
        match = re.search(START_RE, l)
        if not match:
            continue
        name, status = match.groups()
        if status in ('passed', 'failed'):
            res.append(name)
    return res



builds_xml = get_content(BUILDS_URL)
answer = et.fromstring(builds_xml)
build_ids = [build.attrib['id'] for build in answer]

checked_count = 0
stats = defaultdict(int)
stats_by_tests = defaultdict(int)
for build_id in build_ids:
    try:
        failed_tests = get_retried_tests(build_id)
        print len(failed_tests)
        stats[len(failed_tests)] += 1
        for t in failed_tests:
            stats_by_tests[t] += 1
        checked_count += 1
        if checked_count == 500:
            break
    except urllib2.HTTPError:
        logging.warning('Missing log')

print stats
for k,v in stats_by_tests.iteritems():
    print k, v
