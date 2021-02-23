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
import glob
import shutil

BGTHREAD = None

def get_file_progress_file_object_class(on_progress):
    class FileProgressFileObject(tarfile.ExFileObject):
        def read(self, size, *args):
            on_progress(self.name, self.position, self.size)
            return tarfile.ExFileObject.read(self, size, *args)
    return FileProgressFileObject

class TestFileProgressFileObject(tarfile.ExFileObject):
    def read(self, size, *args):
        on_progress(self.name, self.position, self.size)
        return tarfile.ExFileObject.read(self, size, *args)

class ProgressFileObject(io.FileIO):
    def __init__(self, path, *args, **kwargs):
        self._total_size = os.path.getsize(path)
        io.FileIO.__init__(self, path, *args, **kwargs)

    def read(self, size):
        print("Overall process: %d of %d" %(self.tell(), self._total_size))
        rez=[10+(float(self.tell())/float(self._total_size))*90,"Extract transmission"]
        pyotherside.send('progressinstaller', rez)
        return io.FileIO.read(self, size)

def on_progress(filename, position, total_size):
    print("%s: %d of %s" %(filename, position, total_size))

class InstallThread(Thread):
    def __init__(self):
        Thread.__init__(self)
    
    def run(self):
        rez=[0,"Prepare"]
        pyotherside.send('progressinstaller', rez)
        time.sleep(0.01)
        if os.path.exists(glob.CACHEPATH+"/transmission"):
            shutil.rmtree(glob.CACHEPATH+"/transmission", ignore_errors=True)
        if os.path.exists(glob.CACHEPATH+"/config.cnf"):
            os.remove(glob.CACHEPATH+"/config.cnf")
        # sizeF=os.path.getsize(glob.SCRIPTPATH+"/transmission_armv7l.tar.bz2")/(1024*16)
        # i=0
        # in_file = open(glob.SCRIPTPATH+"/transmission_armv7l.tar.bz2", "rb")
        # out_file = open(glob.DATAPATH+"/transmission.tar.bz2", "wb")
        # data = in_file.read(1024*16)
        # txt="Copy transmission.tar.bz2"
        # while data:
        #     out_file.write(data)
        #     i+=1
        #     rez=[i/sizeF*100,txt]
        #     pyotherside.send('progressinstaller', rez)
        #     time.sleep(0.01)
        #     data = in_file.read(1024*16)           
        # out_file.close()
        # in_file.close()
        rez=[10,"Extract transmission"]
        pyotherside.send('progressinstaller', rez)
        time.sleep(0.01)
        #tf = tarfile.open(glob.SCRIPTPATH+"/transmission_armv7l.tar.bz2")
        #tf.extractall(glob.DATAPATH)
        #tf.close()
        tarfile.TarFile.fileobject = get_file_progress_file_object_class(on_progress)
        tar = tarfile.open(fileobj=ProgressFileObject(glob.SCRIPTPATH+"/transmission_armv7l.tar.bz2"))
        tar.extractall(glob.DATAPATH)
        tar.close()
        rez=[90,"Cleaning"]
        pyotherside.send('progressinstaller', rez)
        time.sleep(0.01)
        if os.path.exists(glob.DATAPATH+"/transmission.tar.bz2"):
            os.remove(glob.DATAPATH+"/transmission.tar.bz2")
        rez=[100,"Success transmission install."]
        pyotherside.send('finishedinstaller', rez)

def install():
    global BGTHREAD
    BGTHREAD=InstallThread()
    BGTHREAD.start()

def checkproc():
    ans=str(platform.processor())
    return ans