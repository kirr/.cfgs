import os
import re
import subprocess
import sys
import urllib

def parse_repository_url(s):
    #TODO(kirr) support different types of git url
    expr = r'(\w+://)?git@(?P<host>[\w\.]+):?/?(?P<project>[\w\~]+)/(?P<repo>\w+)\.git'
    match = re.match(expr, s)
    if match is None:
        print('parsing failed: {0}'.format(s))
        return ('','','')

    host = match.group("host")
    project = match.group("project")
    repo = match.group("repo")
    return (host, project, repo)

def get_relative_path(file_path, folder_list):
    for folder in folder_list:
        if file_path.startswith(folder):
            file_path = file_path[len(folder)+1:]
            break
    file_path = file_path.replace('\\', '/')
    return file_path

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

if len(sys.argv) != 3:
    sys.exit('Error: wrong arguments count')

line_number = sys.argv[2]
full_path = sys.argv[1]

current_dir = os.path.dirname(full_path)
print current_dir
root_folder = exe(['git', 'rev-parse', '--show-toplevel'], current_dir).strip()

file_path = get_relative_path(full_path, [root_folder])
current_branch = exe(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], current_dir).strip()
repo_url = exe(['git', 'config', '--get', 'remote.origin.url'], current_dir)

host, project, repo = parse_repository_url(repo_url)
if host != 'stash.desktop.dev.yandex.net':
    print('stash server url is invalid')
    sys.exit()

url_params = '?at={0}'.format(urllib.quote_plus('refs/heads/' + current_branch))
url = 'https://{0}/projects/{1}/repos/{2}/browse/{3}{4}#{5}'.format(host, project, repo, file_path, url_params, line_number)
os.system("echo '%s' | pbcopy" % url)
print url + " is copied to clipboard"
os.system('open ' + url)

