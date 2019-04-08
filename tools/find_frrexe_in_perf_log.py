import re
from collections import defaultdict
import sys

def _parse_line(l, index):
    start_pattern = re.compile('^\[\d+/\d+\]')
    if not re.search(start_pattern, l):
        return None, None
    words = l.split()
    test_name = words[1]
    w = next((w for w in words if w in ['queued', 'passed', 'failed', 'skipped']), None)
    if w:
        return test_name, w
    else:
        raise Exception('Failed to parse {} at {}'.format(test_name, index))

def print_not_finished(lines):
    running_tests = set()
    for index, l in enumerate(lines):
        test_name, status = _parse_line(l, index)
        if not test_name:
            continue

        if status == 'queued':
            running_tests.add(test_name)
        elif status in ['passed', 'failed', 'skipped']:
            running_tests.remove(test_name)
    print running_tests


def print_difference(lines_left, lines_right, statuses):
    def get_tests_with_status(lines, statuses):
        tests = set()
        for index, l in enumerate(lines):
            test_name, test_status = _parse_line(l, index)
            if not test_name:
                continue

            if test_status in statuses:
                tests.add(test_name)
        return tests

    tests_left = get_tests_with_status(lines_left, statuses)
    tests_right = get_tests_with_status(lines_right, statuses)
    print 'Only in right:', tests_right - tests_left
    print 'Only in left:', tests_left - tests_right


def print_time(lines):
    running_tests = defaultdict(list)
    for index, l in enumerate(lines):
        try:
            if 'All WPR archives are downloaded' in l:
                words = l.split()
                test_name = 'Download WPRs'
                time = float(words[6])
            elif 'Download of ' in l and 'finished' in l:
                words = l.split()
                test_name = 'Download files'
                time = float(words[words.index('Took') + 1])
            elif 'Get Http urls of ' in l and 'finished' in l:
                words = l.split()
                test_name = 'Get sandbox HTTP urls'
                time = float(words[words.index('Took') + 1])
            else:
                if len(l) < 2 or l[0] != '[' or not l[1].isdigit():
                    continue
                words = l.split()
                test_name = words[1]
                ind = next((words.index(w) for w in ['passed', 'failed'] if w in words), -1)
                if ind == -1:
                    if any(w in words for w in ['queued', 'skipped']):
                        continue
                    assert False, "Unsupported line format:%s" % l
                offset = 2 if 'failed' in words else 1
                time = words[ind + offset]
                time = float(time[:-2])
            running_tests[test_name].append(time)
        except Exception as e:
            print 'Error in line:%s msg:%s line:%d' % (index, str(e), sys.exc_info()[-1].tb_lineno)

    def sort_value(v):
        return sum(v[1])
    sorted_list = sorted(running_tests.iteritems(), key=sort_value, reverse=True)
    total_time = sum(sum(x for x in v[1]) for v in sorted_list)
    print '\n'.join(['{} - {} sum:{} count:{}'.format(v[0], v[1], sum(v[1]), len(v[1])) for v in sorted_list])
    print 'Total time: {}'.format(total_time)


def preprocess_file(content):
    reg_exps = [
        (re.compile('queued(\d|\[|Traceback|tail)'), r'queued\n \1')
    ]
    for regexp, replace in reg_exps:
        content = regexp.sub(replace, content)
    return content

log_file_left = sys.argv[1]
log_file_right = sys.argv[2] if len (sys.argv) > 2 else None

with open(log_file_left) as f:
    content = preprocess_file(f.read())
    lines_left = content.splitlines()

lines_right = []
if log_file_right:
    with open(log_file_right) as f:
        content = preprocess_file(f.read())
        lines_right = content.splitlines()

print_not_finished(lines_left)
# print_time(lines_left)
# print_difference(lines_left, lines_right, ['queued'])

