import os
import subprocess

RECORD_WPR_TOOL = os.path.join('tools', 'perf', 'record_wpr')
BENCHMARK = 'desktop_memory_system_health'
PAGES = [
    #'load:news:nytimes',
    #'browse:news:flipboard',
    #'browse:news:nytimes',
    'browse:media:youtube',
    #'load:games:alphabetty',
    #'load:media:soundcloud',
    #'load:search:yandex',
    #'load:social:instagram',
    #'load:social:vk',
    #'load:tools:stackoverflow'
]

for p in PAGES:
    cmd = [RECORD_WPR_TOOL, BENCHMARK,
           '--browser=release-custo', '--story-filter={}'.format(p)]
    subprocess.check_call(cmd)
