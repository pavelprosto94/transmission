import os

APP_PKG_NAME = os.path.abspath(__file__)
APP_PKG_NAME = APP_PKG_NAME[APP_PKG_NAME.find(".com/")+5:]
APP_PKG_NAME = APP_PKG_NAME[:APP_PKG_NAME.find("/")]
SCRIPTPATH = os.path.abspath(__file__)
SCRIPTPATH = SCRIPTPATH[:SCRIPTPATH.rfind('/')]

CACHEPATH = "/home/phablet/.cache/"+APP_PKG_NAME
DATAPATH = "/home/phablet/.local/share/"+APP_PKG_NAME
CONFIGPATH = "/home/phablet/.config/"+APP_PKG_NAME

ARCH_TRIPLET=os.getenv("UBUNTU_APP_LAUNCH_ARCH")
BINPATH=os.getenv("APP_DIR") + "/lib/" + ARCH_TRIPLET +"/bin"
LIBPATH=os.getenv("APP_DIR") + "/lib/" + ARCH_TRIPLET

DOWNLOADPATH = CACHEPATH+"/Download"
TMPPATH = CACHEPATH+"/tmp"
RESUMEPATH   = CACHEPATH+"/resume/"
TORRENTSPATH = CACHEPATH+"/torrents/"

MY_ENV = {"HOME" : CACHEPATH }
MY_ENV["PWD"] = CACHEPATH
MY_ENV["TMPDIR"] = CACHEPATH+"/tmp"
MY_ENV["PATH"] = DATAPATH+"/transmission/bin"
MY_ENV["LD_LIBRARY_PATH"] = DATAPATH+"/transmission/lib/:"+LIBPATH
MY_ENV["PKG_CONFIG_PATH"] = DATAPATH+"/transmission/lib/pkgconfig"

if not os.path.exists(DATAPATH):
    try:
        os.makedirs(DATAPATH)
    except Exception as e:
        print("Can't create DATAPATH dir:\n"+DATAPATH)
        print(e)

if not os.path.exists(CONFIGPATH):
    try:
        os.makedirs(CONFIGPATH)
    except Exception as e:
        print("Can't create CONFIGPATH dir:\n"+CONFIGPATH)
        print(e)

if not os.path.exists(CACHEPATH):
    try:
        os.makedirs(CACHEPATH)
    except Exception as e:
        print("Can't create CACHEPATH dir:\n"+CACHEPATH)
        print(e)

if not os.path.exists(DOWNLOADPATH):
    try:
        os.makedirs(DOWNLOADPATH)
    except Exception as e:
        print("Can't create DOWNLOAD dir:\n"+DOWNLOADPATH)
        print(e)

if not os.path.exists(TMPPATH):
    try:
        os.makedirs(TMPPATH)
    except Exception as e:
        print("Can't create TMP dir:\n"+TMPPATH)
        print(e)