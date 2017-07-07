
__author__ = "Michael He(GUCHEZW) +86 13910665776"
__version__ = "10.0506"

import re
outf = open("out.log", "w")
try: plexf= open("StateInPlex.txt")
except IOError:
    print ("file StateInPlex.txt must be in the same directory as this program",file=outf)
    exit
try:
    f1= open ("site.log")
except IOError:
    print ("file RmccState.log must be in the same directory as this program",file=outf)
    else:
    StateDir={}
    StateList=[]
    StateInPlex={}
    info=[]
    CauseDir={}
    CauseList=[]
    ReqExecfidList=[]
    CfmExecfidList=[]
    RefExecfidList=[]
    ExecfidList=[]
    ExecfidCauseList=[]
    ConnectionSetupReq=0
    ConnectionSetupCfm=0
    ConnectionSetupRef=0
    Mstate= "UNKNOWN"
    for line in f1:
        if line.find("RMCC     VAR")>-1:
            Mstate= "RMCC VAR"
            continue
        if line.find("EXECFID=")>-1:
            info=re. split("=",line)
            info=re. split("\n",info[1])
            EXECFID=info[0]
            continue
        if line.find("RTCOSNDINAMSGC ON")>-1:
            Mstate= "RTCOSNDINAMSGC"
            if EXECFID not in ReqExecfidList:
                ReqExecfidList.append(EXECFID)
            if EXECFID not in ExecfidList:
                ExecfidList.append(EXECFID)
            ConnectionSetupReq+=1
            continue
        if line.find("RMINMSGCONFIRM ON")>-1:
            Mstate= "RMINMSGCONFIRM"
            if EXECFID not in CfmExecfidList:
                CfmExecfidList.append(EXECFID)
            if EXECFID not in ExecfidList:
                ExecfidList.append(EXECFID)
            ConnectionSetupCfm+=1
            continue
        if line.find("C7CREFIND2 ON")>-1:
            Mstate= "C7CREFIND2"
            if EXECFID not in RefExecfidList:
                RefExecfidList.append(EXECFID)
            if EXECFID not in ExecfidList:
                ExecfidList.append(EXECFID)
            ConnectionSetupRef+=1
            continue
        if Mstate== "C7CREFIND2":
            if line.find("H'0000 ")>-1:
                info=re.split("," ,line)
                ExecfidCauseList.append(info[2])
                if info[2] not in CauseList:
                    CauseList.append(info[2])
                    CauseDir[info[2]]=1
                else:
                    CauseDir[info[2]]+=1
                Mstate="UNKNOWN"
            continue

        if Mstate=="RMCC VAR" :
            info=re.split(":" ,line)
            if len(info)>=2:
                if info[1].find("......)")>-1:
                    info[1]=info[1]. strip('.)')
                    for i in range (1,len(info)-1) :
                        if info[i] not in StateList:
                            StateList.append(info[i])
                            StateDir[info[i]]=1
                        else:
                            StateDir[info[i]]+=1
            continue
    for line in plexf:
        line=line.lstrip ( ' ')
        line=line.rstrip ( '\n')
        info=re.split("  *",line)
        if len(info)==2:
            StateInPlex[info[0]]=info[1]

    print ("--RMCC STATE ANALYSIS--",file=outf)
    print ("",file=outf)
    for state in StateList:
        IntState=state.strip ( "H'")
        strOut = "The number of individual at State %-14s = %d" %(StateInPlex [str(int(IntState,16))], StateDir[ state])
        print (strOut,file=outf)

        print ("",file=outf)
        print ("--SCCP CONNECTION ANALYSIS--",file=outf)
        print ("",file=outf)
        print ("SCCP CONNECTION SETUP REQUEST:", ConnectionSetupReq,file=outf)
        print ("SCCP CONNECTION SETUP CONFIRM:", ConnectionSetupCfm,file=outf)
        print ("SCCP CONNECTION SETUP REFUSAL:", ConnectionSetupRef,file=outf)
        print ("",file=outf)

        for cause in CauseList:
            StrOut = "The number of refusal with cause value%s = %d" %(cause, CauseDir[cause])
            print (StrOut,file=outf)

            print("",file=outf)
            print ("EXECFID     Request Confirm Refusal RefusalCause",file=outf)

            n=0;
            for EXECFID in ExecfidList:
                if EXECFID in ReqExecfidList:
                    Req=1
                else:
                    Req=0
                if EXECFID in CfmExecfidList:
                    Cfm=1
                else:
                    Cfm=0
                if EXECFID in RefExecfidList:
                    Ref=1
                    StrOut = "%s    %d       %d       %d   %s" %(EXECFID,Req, Cfm,Ref, ExecfidCauseList[n])
                    n=n+1
                else:
                    Ref=0
                    StrOut = "%s    %d       %d       %d" %(EXECFID,Req,Cfm ,Ref)
                print (StrOut,file=outf)


                f1.close()
                outf.close()

