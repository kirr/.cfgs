import subprocess
import sys

EXPERIMENTS = sorted(['scl', 'edn', 'SubresourceInfoCollection', 'zes', 'edt', 'JoinThreadWorkaround', 'tso', 'ocm', 'nbbl', 'hrl', 'skf', 'wrr', 'eif', 'cntb', 'opr', 'scb', 'zen', 'nyatr', 'cd1', 'db1', 'db2', 'tbf', 'qs', 'emhs', 'crd', 'zdd', 'spins', 'cmp', 't1', 'dlb', 'ipwd', 'bda', 'rr', 'ad_hide', 'esb', 'foc', 'mdls', 'smb', 'sb', 'hsh', 'zbl', 'vrb', 'te1', 'ydt', 'bkrd', 'dks', 'nohw', 'fnp', 'od', 'DirectWriteFontProxy', 'acq', 'ntsk', 'crl', 'dkn', 'pop', 'zav', 'DataReductionTrustedSpdyProxy', 'IPCDemuxerExperiment', 'dnc', 'dcvr', 'gpf', 'mss', 'msp', 'yal', 'syr', 'sbm', 'hwdx11', 'turbo', 'pwp', 'NewTabWebContentsCreator', 'isrp', 'vtchk', 'PDO', 'ant', 'Precache', 'bel', 'zss', 'QUIC', 'zsc', 'zsm', 'fld', 'raf', 'ehwd', 'uas', 'inp', 'sad', 'sxp', 'prt', 'spk', 'myl', 'spa', 'zoa', 'csh', 'hps', 'zon', 'fs3', 'sie', 'zvt', 'wpm', 'pr1', 'vvd', 'PrelaunchRenderers', 'ifchk', 'urr', 'zfl'])

obsolete_experiments = []
for e in EXPERIMENTS:
    print 'Check: ' + e
    command = ['git', 'grep', '-n', '"{}"'.format(e),
               '--', '*.cc', '*.h', '*.mm']
    #command = ['git', 'log', '--oneline', '-3', '-S', '"{}"'.format(e),
               #'--', '*.cc', '*.h', '*.mm']
    p = subprocess.Popen(command,
                         cwd=sys.argv[1],
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if not stdout:
        print e + ' is possibly obsolete'
        obsolete_experiments.append(e)
    else:
        print stdout
print 'Obsoletes: ' + str(obsolete_experiments)
