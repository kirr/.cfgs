from collections import defaultdict
import sys

def print_not_finished(lines):
    running_tests = set()
    for index, l in enumerate(lines):
        if l[0] != '[':
            continue
        words = l.split()
        test_name = words[1]
        if 'queued' in words:
            running_tests.add(test_name)
        elif any(w in words for w in ['passed', 'failed', 'skipped']):
            running_tests.remove(test_name)
        else:
            raise Exception('Failed to parse {} at {}'.format(test_name, index))
    print running_tests


def print_time(lines):
    running_tests = defaultdict(list)
    for index, l in enumerate(lines):
        if l[0] != '[' or not l[1].isdigit():
            continue
        try:
            words = l.split()
            test_name = words[1]
            ind = next((words.index(w) for w in ['passed', 'failed'] if w in words), -1)
            if ind == -1:
                if any(w in words for w in ['queued', 'skipped']):
                    continue
                assert False, "Unsupported line format:%s" % l
            time = words[ind+1]
            time = float(time[:-2])
            running_tests[test_name].append(time)
        except Exception as e:
            print 'Error in line:%s msg:%s' % (index, e.message)

    def sort_value(v):
        return v[1][0]
    sorted_list = sorted(running_tests.iteritems(), key=sort_value, reverse=True)
    print '\n'.join(['{} - {}'.format(v[0], v[1]) for v in sorted_list])


log_file = sys.argv[1]
with open(log_file) as f:
    lines = f.readlines();
print_not_finished(lines)
# print_time(lines)

