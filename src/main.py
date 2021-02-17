import pyotherside
import subprocess
import shlex
import shutil
import re
from threading import Thread
import os
import time
import viewer
import sys
import glob

DLIMIT="-d 512"
ULIMIT="-u 256"
ENCRYPTION="-et"

CMD="transmission-cli"
CMD=CMD+" --config-dir \""+glob.CACHEPATH+"/\" -p <port> -w \""+glob.DOWNLOADPATH+"/\" <dlimit> <ulimit> <encryption>"
IGNORE = []
BGTHREAD = []
PAUSETORRENT = []

def gettorrentpath():
    #print ("set cachepath:"+glob.CACHEPATH)
    return glob.CACHEPATH

def movefile(namef):
    #print ("set move file:"+namef)
    ans=0
    if namef[namef.rfind("."):]==".torrent":
        if not os.path.exists(glob.CACHEPATH+namef[namef.rfind("/"):]):
            ans=1
        else:
            ans=-1
    return ans

def settingsLoad():
    global DLIMIT
    global ULIMIT
    global ENCRYPTION
    if os.path.exists(glob.CONFIGPATH+"/config.cnf"):
        fo = open(glob.CONFIGPATH+"/config.cnf", "r")
        txt=fo.read()
        txt=txt.split("\n")
        fo.close()
        if len(txt)>0:
            DLIMIT=txt[0]
        if len(txt)>1:
            ULIMIT=txt[1]
        if len(txt)>2:
            ENCRYPTION=txt[2]

def savesettings(setarray):
    global DLIMIT
    global ULIMIT
    global ENCRYPTION
    global BGTHREAD
    if setarray[0]=="no limit":
        DLIMIT="-D"
    elif " kB/s" in setarray[0]:
        t=setarray[0][:setarray[0].find(" ")]
        t=int(t)
        DLIMIT="-d "+str(t)
    elif " mB/s" in setarray[0]:
        t=setarray[0][:setarray[0].find(" ")]
        t=int(t)*1024
        DLIMIT="-d "+str(t)
    if setarray[1]=="no limit":
        ULIMIT="-U"
    elif " kB/s" in setarray[1]:
        t=setarray[1][:setarray[1].find(" ")]
        t=int(t)
        ULIMIT="-u "+str(t)
    elif " mB/s" in setarray[1]:
        t=setarray[1][:setarray[1].find(" ")]
        t=int(t)*1024
        ULIMIT="-u "+str(t)
    if setarray[2]==0: ENCRYPTION="-er"
    if setarray[2]==1: ENCRYPTION="-ep"
    if setarray[2]==2: ENCRYPTION="-et"
    txt=DLIMIT+"\n"+ULIMIT+"\n"+ENCRYPTION+"\n"
    fo = open(glob.CONFIGPATH+"/config.cnf", "w")
    fo.write(txt)
    fo.close()
   
    for ind in range(0,len(BGTHREAD)):
        if BGTHREAD[ind]!=None:
            filename=BGTHREAD[ind].FILENAME
            if not filename in PAUSETORRENT:
                BGTHREAD[ind]._stop()
                BGTHREAD[ind]=TransmissionThread(filename,ind,True)
                BGTHREAD[ind].start()
                pyotherside.send('progress_sh', [ind,"_up","Resume..."])

def getsettings():
    dl="no limit"
    ul="no limit"
    el=2
    if "-d" in DLIMIT:
        t=DLIMIT[DLIMIT.find(" ")+1:]
        t=int(t)
        if t<1024:
            dl=str(t)+" kB/s"
        else:
            dl=str(int(t/1024))+" mB/s"
    if "-u" in ULIMIT:
        t=ULIMIT[ULIMIT.find(" ")+1:]
        t=int(t)
        if t<1024:
            ul=str(t)+" kB/s"
        else:
            ul=str(int(t/1024))+" mB/s"
    if ENCRYPTION=="-er":
        el=0
    elif  ENCRYPTION=="-ep":
        el=1
    ans=[dl, ul, el]
    return ans

def strip_color(s):
    return re.sub('\x1b\\[(K|.*?m)', '', s)

class TransmissionThread(Thread):
    def __init__(self, filename, ind=-1, rez=False):
        Thread.__init__(self)
        self.FILENAME = filename
        self.PROCESS  = None
        self.PROGRESS  = 0.0
        self.IND = ind
        if not rez:
            adr=self.FILENAME
            name=adr[adr.rfind("/")+1:]
            stat="Pause..."
            fullstat="Pause..."
            ico="_down"
            prval=0
            pyotherside.send('add', [self.IND,adr,name,stat,fullstat,ico,prval])
            time.sleep(0.01) 

    def run(self):
        for stdout_line in self._process(CMD+" \""+self.FILENAME+"\"", glob.CACHEPATH):
            self._work(stdout_line)
            #print(stdout_line)
    
    def _work(self, txt):
        txt=txt.replace("\n","")
        stat=""
        fullstat=txt
        ico="_up"
        prval=self.PROGRESS
        if "Progress:" in txt:
            stat=txt[:txt.rfind(" [")]
            stat=stat.replace("Progress:","Download")
            stat=stat.replace(", dl","")
            stat=stat.replace(", ul ",", upload ")
            tmp=txt[txt.find(":")+1:txt.find("%")]
            prval=float(tmp)
            if prval>self.PROGRESS:
                self.PROGRESS=prval
            else:
                prval=self.PROGRESS
        elif "Seeding," in txt:
            ico="_share"
            if self.PROGRESS!=100:
                self.PROGRESS=100
                prval=self.PROGRESS
            stat=txt[:txt.rfind(" [")]
        else:
            stat="Conecting..."
        pyotherside.send('progress', [self.IND,stat,fullstat,ico,prval])

    def _process(self, command_string, path=""):
        command_string=command_string.replace("<port>",str(51413+self.IND))
        command_string=command_string.replace("<dlimit>",DLIMIT)
        command_string=command_string.replace("<ulimit>",ULIMIT)
        command_string=command_string.replace("<encryption>",ENCRYPTION)
        print(path+"$ "+command_string+"\n")
        cmd_args = shlex.split(command_string)
        try:
            self.PROCESS = subprocess.Popen(cmd_args,
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
            for stdout_line in iter(self.PROCESS.stdout.readline, ''):
                yield strip_color(stdout_line)
            self.PROCESS.stdout.close()
            return_code = self.PROCESS.wait()
            if return_code:
                raise subprocess.CalledProcessError(return_code, command_string)

    def _stop(self):
        if self.PROCESS != None:
            self.PROCESS.kill()
        print("end:"+self.FILENAME)

def transmission_create(filename="",ind=-1):
    global BGTHREAD
    if ind==-1:
        ind=len(BGTHREAD)
        BGTHREAD.append(TransmissionThread(filename,ind))
        if not filename in PAUSETORRENT:
            BGTHREAD[ind].start()

def pauseTorrentLoad():
    global PAUSETORRENT
    if os.path.exists(glob.CACHEPATH+"/pause.list"):
        fo = open(glob.CACHEPATH+"/pause.list", "r")
        txt=fo.read()
        PAUSETORRENT=txt.split("\n")
        fo.close()

def pauseTorrentSave():
    txt=""
    for t in PAUSETORRENT:
        if t!="":
            txt+=t+"\n"
    fo = open(glob.CACHEPATH+"/pause.list", "w")
    fo.write(txt)
    fo.close()

def transmission_stop(ind=-1):
    global BGTHREAD
    if (ind>-1):
        filename=BGTHREAD[ind].FILENAME
        PAUSETORRENT.append(filename)
        pauseTorrentSave()
        BGTHREAD[ind]._stop()
        time.sleep(0.5)
        pyotherside.send('progress_sh', [ind,"_down","Pause..."])

def transmission_resume(ind=-1):
    global BGTHREAD
    if (ind>-1):
        filename=BGTHREAD[ind].FILENAME
        PAUSETORRENT.remove(filename)
        pauseTorrentSave()
        BGTHREAD[ind]=TransmissionThread(filename,ind,True)
        BGTHREAD[ind].start()
        pyotherside.send('progress_sh', [ind,"_up","Resume..."])

def transmission_remove(ind=-1):
    global BGTHREAD
    if (ind>-1):
        filename=BGTHREAD[ind].FILENAME
        if filename in PAUSETORRENT:
            PAUSETORRENT.remove(filename)
            pauseTorrentSave()
        BGTHREAD[ind]._stop()
    
        listfiles=viewer.listFiles(filename)
        if len(listfiles)==1:
            print("remove file:"+listfiles[0])
            if os.path.exists(listfiles[0]):
                os.remove(listfiles[0])
            else:
                if os.path.exists(listfiles[0]+".part"):
                    os.remove(listfiles[0]+".part")

            shot_filename=listfiles[0]
            shot_filename=shot_filename[shot_filename.rfind("/")+1:]
            for filetmp in os.listdir(glob.RESUMEPATH):
                if shot_filename == filetmp[:len(shot_filename)]:
                    adr=os.path.join(glob.RESUMEPATH, filetmp)
                    print("remove:"+adr)
                    if os.path.exists(adr):
                        os.remove(adr)
                    else:
                        print("File not exist:"+filetmp[:len(shot_filename)])
                    break
            for filetmp in os.listdir(glob.TORRENTSPATH):
                if shot_filename == filetmp[:len(shot_filename)]:
                    adr=os.path.join(glob.TORRENTSPATH, filetmp)
                    print("remove:"+adr)
                    if os.path.exists(adr):
                        os.remove(adr)
                    else:
                        print("File not exist:"+filetmp[:len(shot_filename)])
                    break
        else:
            shot_filename=listfiles[0]
            shot_filename=shot_filename[len(glob.DOWNLOADPATH)+1:]
            shot_filename=shot_filename[:shot_filename.find("/")]
            print("remove dir:"+glob.DOWNLOADPATH+"/"+shot_filename)
            shutil.rmtree(glob.DOWNLOADPATH+"/"+shot_filename, ignore_errors=True)
            for filetmp in os.listdir(glob.RESUMEPATH):
                if shot_filename == filetmp[:len(shot_filename)]:
                    adr=os.path.join(glob.RESUMEPATH, filetmp)
                    print("remove:"+adr)
                    if os.path.exists(adr):
                        os.remove(adr)
                    else:
                        print("File not exist:"+filetmp[:len(shot_filename)])
                    break
            for filetmp in os.listdir(glob.TORRENTSPATH):
                if shot_filename == filetmp[:len(shot_filename)]:
                    adr=os.path.join(glob.TORRENTSPATH, filetmp)
                    print("remove:"+adr)
                    if os.path.exists(adr):
                        os.remove(adr)
                    else:
                        print("File not exist:"+filetmp[:len(shot_filename)])
                    break
        
        print("remove:"+filename)
        if os.path.exists(filename):
            os.remove(filename)
        else:
            print("File not exist:"+filename)
        BGTHREAD[ind]=None
        pyotherside.send('removeitem', ind)

def slow_function(path=glob.CACHEPATH):
    global BGTHREAD
    pauseTorrentLoad()
    settingsLoad()
    for filename in os.listdir(path):
        if filename.find(".torrent")>-1:
            sootv=False
            adr=os.path.join(glob.CACHEPATH, filename)
            for i in range(0,len(BGTHREAD)):
                if BGTHREAD[i]!=None:
                    if BGTHREAD[i].FILENAME==adr:
                        sootv=True
                        break
            if sootv==False:
                transmission_create(adr)
    pyotherside.send('finished')

def check_transmission():
    ans=False
    if os.path.exists(glob.DATAPATH+"/transmission"):
        ans=True
    return ans

def remove_transmission_lib():
    if os.path.exists(glob.DATAPATH+"/transmission"):
        for ind in range(0,len(BGTHREAD)):
            if BGTHREAD[ind]!=None:
                transmission_stop(ind)
        time.sleep(1)
        shutil.rmtree(glob.DATAPATH+"/transmission", ignore_errors=True)
            