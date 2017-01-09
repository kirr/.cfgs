import sys

file_name = sys.argv[1]

lines = []
with open(file_name) as f:
    lines = f.readlines()

vmap = {}
for l in lines[1:]:
    fields = l.split(',')
    vmap.setdefault(fields[-2], []).append(float(fields[-1]))

for k, v in vmap.iteritems():
    v.sort()
    median = v[len(v)/2]

    deviations = [abs(val - median)*100/median for val in v]
    deviations.sort()

    print k
    print median
    print deviations
