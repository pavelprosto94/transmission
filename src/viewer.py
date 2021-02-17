import pyotherside
import subprocess
import os
import re
import shlex
import glob

CMD="transmission-show"
def strip_color(s):
    return re.sub('\x1b\\[(K|.*?m)', '', s)

def _process(command_string, path=""):
        cmd_args = shlex.split(command_string)
        try:
            PROCESS = subprocess.Popen(cmd_args,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT,
                                universal_newlines=True,
                                shell=False,
                                executable=None,
                                env=glob.MY_ENV,
                                cwd=path)
        except Exception as e:
            yield strip_color(str(e))
        else:
            for stdout_line in iter(PROCESS.stdout.readline, ''):
                yield strip_color(stdout_line)
            PROCESS.stdout.close()
            return_code = PROCESS.wait()
            if return_code:
                raise subprocess.CalledProcessError(return_code, command_string)

def listFiles(FILENAME):
    files=[]
    stv=False
    for stdout_line in _process(CMD+" \""+FILENAME+"\"", glob.CACHEPATH):
        if stv==True :
            if " (" in stdout_line:
                files.append(glob.DOWNLOADPATH+"/"+str(stdout_line[2:stdout_line.rfind(" (")]))
        elif "FILES" in stdout_line:
            stv=True
    return(files)

def readfiles(FILENAME):
    for fileadr in listFiles(FILENAME):
        adr=fileadr
        name=str(adr[adr.rfind("/")+1:])
        icon="package-x-generic-symbolic"
        if os.path.exists(adr):
            icon="empty-symbolic"
        rez=[adr,name,icon]
        pyotherside.send('progressviewer', rez)