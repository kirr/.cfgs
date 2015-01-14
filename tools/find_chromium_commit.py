import os
import re
import subprocess
import sys

CHROMIUM_PATH = os.path.expanduser('~') + ('/chromium/src')

if len(sys.argv) != 3:
    sys.exit('Error: wrong arguments count')

changed_string = sys.argv[1]
file_path = sys.argv[2]

file_path = re.sub('^src/', '', file_path)
file_path = re.sub('^yandex/ui', 'chrome/browser/ui', file_path)

git_log_command = ['git', 'log', '-S', changed_string, '-5', '--pretty=oneline', '--', file_path]
process = subprocess.Popen(
    git_log_command,
    cwd=CHROMIUM_PATH,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE)
log_out, log_error = process.communicate(None)
if log_error:
    print log_error;
print log_out

commit = log_out.split(' ', 1)[0]
print commit

os.system('open https://stash.desktop.dev.yandex.net/projects/CHROMIUM/repos/src/commits/' + commit)
#git_show_command = ['git', 'show', '-s', commit]
#process = subprocess.Popen(git_show_command,
    #cwd=CHROMIUM_PATH,
    #stdin=subprocess.PIPE,
    #stdout=subprocess.PIPE,
    #stderr=subprocess.PIPE)
#show_out, show_error = process.communicate(None)
#if show_error:
    #print show_error;
#print show_out

#subprocess.Popen(['git', 'difftool', commit + '^..' + commit], cwd=CHROMIUM_PATH)

#git_diff_command = ['git', 'diff', commit + '^..' + commit, '--', file_path]
#process = subprocess.Popen(git_diff_command,
    #cwd=CHROMIUM_PATH,
    #stdin=subprocess.PIPE,
    #stdout=subprocess.PIPE,
    #stderr=subprocess.PIPE)
#diff_out, diff_error = process.communicate(None)
#if diff_error:
    #print diff_error;
#print diff_out
