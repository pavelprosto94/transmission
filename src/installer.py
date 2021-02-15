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