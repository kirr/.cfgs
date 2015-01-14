import os
import re
import subprocess
import sys
import urllib

def exe(argv, current_directory):
    process = subprocess.Popen(
        argv,
        cwd=current_directory,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    cmd_out, cmd_error = process.communicate(None)
    if cmd_error:
        print cmd_error
    return cmd_out

if len(sys.argv) != 2:
    sys.exit('Error: wrong arguments count')

file_path = sys.argv[1]
current_dir, file_name = os.path.split(file_path)
root_folder = exe(['git', 'rev-parse', '--show-toplevel'], current_dir).strip()
current_dir = os.path.join(root_folder, 'src', 'out', 'Debug')

ninja_process = subprocess.Popen('ninja -nv All | fgrep "%s"'%file_name, stdout=subprocess.PIPE, shell=True, cwd=current_dir)
ninja_out, ninja_error = ninja_process.communicate()
build_line = re.sub('^\[\d+/\d+\]', '', ninja_out)
print build_line

os.chdir(current_dir)
os.system(build_line)
