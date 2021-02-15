import pyotherside
import platform
import subprocess
import shlex
import re
from threading import Thread
import os
import io
import time
import tarfile

CACHEPATH = os.path.abspath(__file__)
CACHEPATH = CACHEPATH[CACHEPATH.find(".com/")+5:]
CACHEPATH = "/home/phablet/.cache/"+CACHEPATH[:CACHEPATH.find("/")]
SCRIPTPATH = os.path.abspath(__file__)
SCRIPTPATH = SCRIPTPATH[:SCRIPTPATH.rfind('/')+1]
BGTHREAD = None

def strip_color(s):
    return re.sub('\x1b\\[(K|.*?m)', '', s)

class cd:
    """Context manager for changing the current working directory"""
    def __init__(self, newPath):
        self.newPath = os.path.expanduser(newPath)

    def __enter__(self):
        self.savedPath = os.getcwd()
        os.chdir(self.newPath)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.savedPath)

def shell_exec(command_string, path=CACHEPATH):
    yield path+"$ "+command_string+"\n"
    #os.chdir(path)
    cmd_args = shlex.split(command_string)
    try:
        process = subprocess.Popen(cmd_args,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            universal_newlines=True,
                            cwd=path
                            )
    except Exception as e:
        yield strip_color(str(e))
    else:
        for stdout_line in iter(process.stdout.readline, ''):
            yield strip_color(stdout_line)
        process.stdout.close()
        return_code = process.wait()
        if return_code:
            raise subprocess.CalledProcessError(return_code, command_string)

class InstallThread(Thread):
    def __init__(self):
        Thread.__init__(self)
    
    def run(self):
        rez=[0,"txt"]
        sizeF=os.path.getsize(SCRIPTPATH+"transmission_armv7l.tar.bz2")/(1024*16)
        i=0
        in_file = open(SCRIPTPATH+"transmission_armv7l.tar.bz2", "rb")
        out_file = open(CACHEPATH+"/transmission.tar.bz2", "wb")
        data = in_file.read(1024*16)
        txt="Copy transmission.tar.bz2"
        while data:
            out_file.write(data)
            i+=1
            rez=[i/sizeF*100,txt]
            pyotherside.send('progressinstaller', rez)
            time.sleep(0.01)
            data = in_file.read(1024*16)           
        out_file.close()
        in_file.close()
        rez=[rez[0],"Extract transmission"]
        pyotherside.send('progressinstaller', rez)
        time.sleep(0.01)
        tf = tarfile.open(CACHEPATH+"/transmission.tar.bz2")
        tf.extractall(CACHEPATH)
        tf.close()
        rez=[rez[0],"Cleaning"]
        pyotherside.send('progressinstaller', rez)
        time.sleep(0.01)
        os.remove(CACHEPATH+"/transmission.tar.bz2")
        rez=[100,"Success transmission install."]
        pyotherside.send('finishedinstaller', rez)

def install():
    global BGTHREAD
    BGTHREAD=InstallThread()
    BGTHREAD.start()

def checkproc():
    ans=str(platform.processor())
    return ans

def checkcmd():
    ans=""
    command_string="transmission/bin/transmission-cli -h"
    for stdout_line in shell_exec(command_string):
        ans+=stdout_line
    return ans