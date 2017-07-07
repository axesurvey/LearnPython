import re


def msg2RarHandling(msg2rarlist):
    msg2rarlist_clean1 = [x for x in msg2rarlist if x != []]
    msg2rarlist_clean2 = [x for x in msg2rarlist_clean1 if len(x) != 1]
    cellId = 99999
    subframe = 99999
    sfn = 99999
    preambleId = 99999
    taCommand = 99999
    ulGrant = 99999
    temporaryCrnti = 99999
    bbUeRef = 99999
    prachCeLevel = 99999
    title = "cellId     sfn        subframe   preambleId bbUeRef    taCommand  ulGrant              prachCeLevel         temporaryCrnti"

    #print title
    for i in msg2rarlist_clean2:
        if i[0] == "cellId":
            cellId = int(i[1])
        elif i[0] == "subframeRach":
            subframe = int(i[1])
        elif i[0] == "sfnRach":
            sfn = int(i[1])
        elif i[0] == "preambleId":
            preambleId = int(i[1])
        elif i[0] == "taCommand":
            taCommand = int(i[1])
        elif i[0] == "ulGrant":
            ulGrant = int(i[1])
        elif i[0] == "temporaryCrnti":
            temporaryCrnti = int(i[1])
        elif i[0] == "bbUeRef":
            bbUeRef = int(i[1])
        elif i[0] == "prachCeLevel":
            prachCeLevel = int(i[1])
    msg2rar_handled_data = "%-10d %-10d %-10d %-10d %-10d %-10d %-20d %-20d %-20d" % (cellId, sfn, subframe, preambleId, bbUeRef, taCommand, ulGrant, prachCeLevel, temporaryCrnti)
    return msg2rar_handled_data, title


aa = [['sigNo', '16711680'], ['cellId', '4'], ['subframeRach', '1'], ['sfnRach', '80'], ['raMsg2SequenceNr', '9'], ['msg2size', '1'], ['backOffcontrol', '0'], ['rarArray'], ['rarArray'], ['preambleId', '0'], ['taCommand', '1'], ['ulGrant', '975456'], ['temporaryCrnti', '16611'], [], [], ['bbUeRef'], ['bbUeRef', '71308832'], [], ['prachCeLevel'], ['prachCeLevel', '1'], [], []]
print msg2RarHandling(aa)[1]
print msg2RarHandling(aa)[0]


def msg2MpdcchHandling(msg2mpdcchlist):
    msg2mpdcchlist_clean1 = [x for x in msg2mpdcchlist if x != []]
    msg2mpdcchlist_clean2 = [x for x in msg2mpdcchlist_clean1 if len(x) != 1]
    cellId = [99999]
    subframe = [99999]
    sfn = [99999]
    preambleId = [99999]
    taCommand = [99999]
    ulGrant = [99999]
    temporaryCrnti = [99999]
    bbUeRef = [99999]
    prachCeLevel = [99999]
    totalNrOfSets = [99999]
    totalNrOfMpdcchDci = [99999]
    startSymbol = [99999]
    startPrb = [99999]
    rnti = [99999]
    deltaPsd = [99999]
    cceIndex = [99999]
    nrOfCce = [99999]
    nrOfRbaBits = [99999]
    startRbaBit = [99999]
    rbaBits = [99999]
    nrOfPayloadBit = [99999]
    nrOfDtx = [99999]
    cceAllocType = [99999]
    mpdcchSetIndex = [99999]
    servCellIndex = [99999]
    mpdcchBlockIndex = [99999]
    mpdcchCEMode = [99999]
    mpdcchFirstSf = [99999]
    dciMsg = [99999]


    cellIdIndex = 0
    subframeIndex = 0
    sfnIndex = 0
    preambleIdIndex = 0
    taCommandIndex = 0
    ulGrantIndex = 0
    temporaryCrntiIndex = 0
    bbUeRefIndex = 0
    prachCeLevelIndex = 0
    totalNrOfSetsIndex = 0
    totalNrOfMpdcchDciIndex = 0
    startSymbolIndex = 0
    startPrbIndex = 0
    rntiIndex = 0
    deltaPsdIndex = 0
    cceIndexIndex = 0
    nrOfCceIndex = 0
    nrOfRbaBitsIndex = 0
    startRbaBitIndex = 0
    rbaBitsIndex = 0
    nrOfPayloadBitIndex = 0
    nrOfDtxIndex = 0
    cceAllocTypeIndex = 0
    mpdcchSetIndexIndex = 0
    servCellIndexIndex = 0
    mpdcchBlockIndexIndex = 0
    mpdcchCEModeIndex = 0
    mpdcchFirstSfIndex = 0
    dciMsgIndex = 0

    final_data = []
    title = "cellId     sfn        subframe   rnti       bbUeRef    dciMsg     totalNrOfMpdcchDci   nrOfPayloadBit"
    fulltitle = "cellId, subframe, sfn, preambleId, taCommand, ulGrant, temporaryCrnti, bbUeRef, prachCeLevel, totalNrOfSets, totalNrOfMpdcchDci, startSymbol, startPrb, rnti, deltaPsd, cceIndex, nrOfCce, nrOfRbaBits, startRbaBit, rbaBits, nrOfPayloadBit, nrOfDtx, cceAllocType, mpdcchSetIndex, servCellIndex, mpdcchBlockIndex, mpdcchCEMode, mpdcchFirstSf, dciMsg"

    #print title
    for i in msg2mpdcchlist_clean2:
        if i[0] == "cellId":
            if cellIdIndex == 0:
                cellId[0] = int(i[1])
                cellIdIndex += 1
            else:
                cellId.append(int(i[1]))
            final_data.append(cellId)
        elif i[0] == "subframeNr":
            if subframeIndex == 0:
                subframe[0] = int(i[1])
                subframeIndex += 1
            else:
                subframe.append(int(i[1]))
            final_data.append(subframe)
        elif i[0] == "sfn":
            if sfnIndex == 0:
                sfn[0] = int(i[1])
                sfnIndex += 1
            else:
                sfn.append(int(i[1]))
            final_data.append(sfn)
        elif i[0] == "preambleId":
            if preambleIdIndex == 0:
                preambleId[0] = int(i[1])
                preambleIdIndex += 1
            else:
                preambleId.append(int(i[1]))
            final_data.append(preambleId)
        elif i[0] == "taCommand":
            if taCommandIndex == 0:
                taCommand[0] = int(i[1])
                taCommandIndex += 1
            else:
                taCommand.append(int(i[1]))
            final_data.append(taCommand)
        elif i[0] == "ulGrant":
            if ulGrantIndex == 0:
                ulGrant[0] = int(i[1])
                ulGrantIndex += 1
            else:
                ulGrant.append(int(i[1]))
            final_data.append(ulGrant)
        elif i[0] == "temporaryCrnti":
            if temporaryCrntiIndex == 0:
                temporaryCrnti[0] = int(i[1])
                temporaryCrntiIndex += 1
            else:
                temporaryCrnti.append(int(i[1]))
            final_data.append(temporaryCrnti)
        elif i[0] == "bbUeRef":
            if bbUeRefIndex == 0:
                bbUeRef[0] = int(i[1])
                bbUeRefIndex += 1
            else:
                bbUeRef.append(int(i[1]))
            final_data.append(bbUeRef)
        elif i[0] == "prachCeLevel":
            if prachCeLevelIndex == 0:
                prachCeLevel[0] = int(i[1])
                prachCeLevelIndex += 1
            else:
                prachCeLevel.append(int(i[1]))
            final_data.append(prachCeLevel)

        elif i[0] == "totalNrOfSets":
            if totalNrOfSetsIndex == 0:
                totalNrOfSets[0] = int(i[1])
                totalNrOfSetsIndex += 1
            else:
                totalNrOfSets.append(int(i[1]))
            final_data.append(totalNrOfSets)
        elif i[0] == "totalNrOfMpdcchDci":
            if totalNrOfMpdcchDciIndex == 0:
                totalNrOfMpdcchDci[0] = int(i[1])
                totalNrOfMpdcchDciIndex += 1
            else:
                totalNrOfMpdcchDci.append(int(i[1]))
            final_data.append(totalNrOfMpdcchDci)
        elif i[0] == "startSymbol":
            if startSymbolIndex == 0:
                startSymbol[0] = int(i[1])
                startSymbolIndex += 1
            else:
                startSymbol.append(int(i[1]))
            final_data.append(startSymbol)
        elif i[0] == "startPrb":
            if startPrbIndex == 0:
                startPrb[0] = int(i[1])
                startPrbIndex += 1
            else:
                startPrb.append(int(i[1]))
            final_data.append(startPrb)
        elif i[0] == "rnti":
            if rntiIndex == 0:
                rnti[0] = int(i[1])
                rntiIndex += 1
            else:
                rnti.append(int(i[1]))
            final_data.append(rnti)
        elif i[0] == "deltaPsd":
            if deltaPsdIndex == 0:
                deltaPsd[0] = int(i[1])
                deltaPsdIndex += 1
            else:
                deltaPsd.append(int(i[1]))
            final_data.append(deltaPsd)
        elif i[0] == "cceIndex":
            if cceIndexIndex == 0:
                cceIndex[0] = int(i[1])
                cceIndexIndex += 1
            else:
                cceIndex.append(int(i[1]))
            final_data.append(cceIndex)
        elif i[0] == "nrOfCce":
            if nrOfCceIndex == 0:
                nrOfCce[0] = int(i[1])
                nrOfCceIndex += 1
            else:
                nrOfCce.append(int(i[1]))
            final_data.append(nrOfCce)
        elif i[0] == "nrOfRbaBits":
            if nrOfRbaBitsIndex == 0:
                nrOfRbaBits[0] = int(i[1])
                nrOfRbaBitsIndex += 1
            else:
                nrOfRbaBits.append(int(i[1]))
            final_data.append(nrOfRbaBits)
        elif i[0] == "startRbaBit":
            if startRbaBitIndex == 0:
                startRbaBit[0] = int(i[1])
                startRbaBitIndex += 1
            else:
                startRbaBit.append(int(i[1]))
            final_data.append(startRbaBit)
        elif i[0] == "rbaBits":
            if rbaBitsIndex == 0:
                rbaBits[0] = int(i[1])
                rbaBitsIndex += 1
            else:
                rbaBits.append(int(i[1]))
            final_data.append(rbaBits)
        elif i[0] == "nrOfPayloadBit":
            if nrOfPayloadBitIndex == 0:
                nrOfPayloadBit[0] = int(i[1])
                nrOfPayloadBitIndex += 1
            else:
                nrOfPayloadBit.append(int(i[1]))
            final_data.append(nrOfPayloadBit)
        elif i[0] == "nrOfDtx":
            if nrOfDtxIndex == 0:
                nrOfDtx[0] = int(i[1])
                nrOfDtxIndex += 1
            else:
                nrOfDtx.append(int(i[1]))
            final_data.append(nrOfDtx)
        elif i[0] == "cceAllocType":
            if cceAllocTypeIndex == 0:
                cceAllocType[0] = int(i[1])
                cceAllocTypeIndex += 1
            else:
                cceAllocType.append(int(i[1]))
            final_data.append(cceAllocType)
        elif i[0] == "mpdcchSetIndex":
            if mpdcchSetIndexIndex == 0:
                mpdcchSetIndex[0] = int(i[1])
                mpdcchSetIndexIndex += 1
            else:
                mpdcchSetIndex.append(int(i[1]))
            final_data.append(mpdcchSetIndex)
        elif i[0] == "servCellIndex":
            if servCellIndexIndex == 0:
                servCellIndex[0] = int(i[1])
                servCellIndexIndex += 1
            else:
                servCellIndex.append(int(i[1]))
            final_data.append(servCellIndex)
        elif i[0] == "mpdcchBlockIndex":
            if mpdcchBlockIndexIndex == 0:
                mpdcchBlockIndex[0] = int(i[1])
                mpdcchBlockIndexIndex += 1
            else:
                mpdcchBlockIndex.append(int(i[1]))
            final_data.append(mpdcchBlockIndex)
        elif i[0] == "mpdcchCEMode":
            if mpdcchCEModeIndex == 0:
                mpdcchCEMode[0] = int(i[1])
                mpdcchCEModeIndex += 1
            else:
                mpdcchCEMode.append(int(i[1]))
            final_data.append(mpdcchCEMode)
        elif i[0] == "mpdcchFirstSf":
            if mpdcchFirstSfIndex == 0:
                mpdcchFirstSf[0] = int(i[1])
                mpdcchFirstSfIndex += 1
            else:
                mpdcchFirstSf.append(int(i[1]))
            final_data.append(mpdcchFirstSf)
        elif i[0] == "dciMsg":
            if dciMsgIndex == 0:
                dciMsg[0] = int(i[1])
                dciMsgIndex += 1
            else:
                dciMsg.append(int(i[1]))
            final_data.append(dciMsg)

    msg2mpdcch_handled_data1 = "%-10d %-10d %-10d %-10d %-10d %-10d %-20d %-20d" % (cellId[0],sfn[0],subframe[0],rnti[0],bbUeRef[0],dciMsg[0],totalNrOfMpdcchDci[0],nrOfPayloadBit[0])

    return msg2mpdcch_handled_data1,final_data,title, fulltitle


maa = [['sigNo', '4294967295'], ['header'], ['header'], ['cellId', '4'], ['sfn', '80'], ['subframeNr', '5'], [], ['totalNrOfSets', '1'], ['padding0', '65535'], [], ['setList'], ['setList'], ['header'], ['totalNrOfMpdcchDci', '1'], ['padding0', '65535'], [], ['setConfig'], ['setSize', '6'], ['isDistributed', '1'], ['setId', '201'], ['padding0', '0'], ['startSymbol', '2'], ['startPrb', '7'], ['padding1', '0'], ['padding2', '29'], [], ['mpdcch'], ['mpdcch'], ['rnti', '2'], ['deltaPsd', '4096'], ['bbUeRef', '71308832'], ['cceIndex', '0'], ['nrOfCce', '24'], ['nrOfRbaBits', '8'], ['startRbaBit', '2'], ['rbaBits', '721420288'], ['nrOfPayloadBit', '21'], ['admissionCtrlWeightAboveThreshold', '0'], ['admissionCtrlResourceType', '0'], ['seArp', '0'], ['nrOfDtx', '0'], ['cceAllocType', '0'], ['mpdcchSetIndex', '0'], ['servCellIndex', '0'], ['mpdcchBlockIndex', '0'], ['mpdcchCEMode', '0'], ['mpdcchFirstSf', '805'], ['dciMsg'], ['dciMsg', '33808'], ['dciMsg', '0'], [], [], [], [], [], []]
mbb = [['sigNo', '4294967295'], ['header'], ['header'], ['cellId', '4'], ['sfn', '80'], ['subframeNr', '5'], [], ['totalNrOfSets', '1'], ['padding0', '65535'], [], ['setList'], ['setList'], ['header'], ['totalNrOfMpdcchDci', '1'], ['padding0', '65535'], [], ['setConfig'], ['setSize', '6'], ['isDistributed', '1'], ['setId', '201'], ['padding0', '0'], ['startSymbol', '2'], ['startPrb', '7'], ['padding1', '0'], ['padding2', '29'], [], ['mpdcch'], ['mpdcch'], ['rnti', '2'], ['deltaPsd', '4096'], ['bbUeRef', '71308832'], ['cceIndex', '0'], ['nrOfCce', '24'], ['nrOfRbaBits', '8'], ['startRbaBit', '2'], ['rbaBits', '721420288'], ['nrOfPayloadBit', '21'], ['admissionCtrlWeightAboveThreshold', '0'], ['admissionCtrlResourceType', '0'], ['seArp', '0'], ['nrOfDtx', '0'], ['cceAllocType', '0'], ['mpdcchSetIndex', '0'], ['servCellIndex', '0'], ['mpdcchBlockIndex', '0'], ['mpdcchCEMode', '0'], ['mpdcchFirstSf', '805'], ['dciMsg'], ['dciMsg', '33808'], ['dciMsg', '0'], [], [], [], [], [], []]
mcc = [['sigNo', '0'], ['header'], ['header'], ['cellId', '4'], ['sfn', '81'], ['subframeNr', '8'], [], ['totalNrOfSets', '1'], ['padding0', '0'], [], ['setList'], ['setList'], ['header'], ['totalNrOfMpdcchDci', '1'], ['padding0', '0'], [], ['setConfig'], ['setSize', '6'], ['isDistributed', '1'], ['setId', '201'], ['padding0', '2'], ['startSymbol', '2'], ['startPrb', '7'], ['padding1', '0'], ['padding2', '29'], [], ['mpdcch'], ['mpdcch'], ['rnti', '16611'], ['deltaPsd', '4096'], ['bbUeRef', '71308832'], ['cceIndex', '0'], ['nrOfCce', '24'], ['nrOfRbaBits', '8'], ['startRbaBit', '2'], ['rbaBits', '637534208'], ['nrOfPayloadBit', '21'], ['admissionCtrlWeightAboveThreshold', '0'], ['admissionCtrlResourceType', '2'], ['seArp', '0'], ['nrOfDtx', '0'], ['cceAllocType', '0'], ['mpdcchSetIndex', '1'], ['servCellIndex', '0'], ['mpdcchBlockIndex', '0'], ['mpdcchCEMode', '0'], ['mpdcchFirstSf', '8'], ['dciMsg'], ['dciMsg', '2053'], ['dciMsg', '0'], [], [], [], [], [], []]


print msg2MpdcchHandling(maa)[2]
print msg2MpdcchHandling(maa)[0]


def msg2PdschHandling(msg2pdschlist):
    msg2pdschlist_clean1 = [x for x in msg2pdschlist if x != []]
    msg2pdschlist_clean2 = [x for x in msg2pdschlist_clean1 if len(x) != 1]
    cellId = [99999]
    subframe = [99999]
    sfn = [99999]
    rapid = [99999]
    ta = [99999]
    ulGrant = [99999]
    tmpCRnti = [99999]
    rnti = [99999]
    nrOfRar = [99999]
    msgType = [99999]


    cellIdIndex = 0
    subframeIndex = 0
    sfnIndex = 0
    rapidIndex = 0
    taIndex = 0
    ulGrantIndex = 0
    tmpCRntiIndex = 0
    rntiIndex = 0
    nrOfRarIndex = 0
    msgTypeIndex = 0

    final_data = []
    title = "cellId     sfn        subframe   rnti       ulGrant    tmpCRnti   msgType              rapid                ta         nrOfRar"
    #print title
    for i in msg2pdschlist_clean2:
        if i[0] == "cellId":
            if cellIdIndex == 0:
                cellId[0] = int(i[1])
                cellIdIndex += 1
            else:
                cellId.append(int(i[1]))
            final_data.append(cellId)
        elif i[0] == "subframeNr":
            if subframeIndex == 0:
                subframe[0] = int(i[1])
                subframeIndex += 1
            else:
                subframe.append(int(i[1]))
            final_data.append(subframe)
        elif i[0] == "sfn":
            if sfnIndex == 0:
                sfn[0] = int(i[1])
                sfnIndex += 1
            else:
                sfn.append(int(i[1]))
            final_data.append(sfn)
        elif i[0] == "ulGrant":
            if ulGrantIndex == 0:
                ulGrant[0] = int(i[1])
                ulGrantIndex += 1
            else:
                ulGrant.append(int(i[1]))
            final_data.append(ulGrant)
        elif i[0] == "tmpCRnti":
            if tmpCRntiIndex == 0:
                tmpCRnti[0] = int(i[1])
                tmpCRntiIndex += 1
            else:
                tmpCRnti.append(int(i[1]))
            final_data.append(tmpCRnti)
        elif i[0] == "ta":
            if taIndex == 0:
                ta[0] = int(i[1])
                taIndex += 1
            else:
                ta.append(int(i[1]))
            final_data.append(ta)
        elif i[0] == "rapid":
            if rapidIndex == 0:
                rapid[0] = int(i[1])
                rapidIndex += 1
            else:
                rapid.append(int(i[1]))
            final_data.append(rapid)
        elif i[0] == "nrOfRar":
            if nrOfRarIndex == 0:
                nrOfRar[0] = int(i[1])
                nrOfRarIndex += 1
            else:
                nrOfRar.append(int(i[1]))
            final_data.append(nrOfRar)
        elif i[0] == "rnti":
            if rntiIndex == 0:
                rnti[0] = int(i[1])
                rntiIndex += 1
            else:
                rnti.append(int(i[1]))
            final_data.append(rnti)
        elif i[0] == "msgType":
            if msgTypeIndex == 0:
                msgType[0] = int(i[1])
                msgTypeIndex += 1
            else:
                msgType.append(int(i[1]))
            final_data.append(msgType)

    msg2mpdcch_handled_data1 = "%-10d %-10d %-10d %-10d %-10d %-10d %-20d %-20d %-10d %-10d" % (cellId[0],sfn[0],subframe[0],rnti[0],ulGrant[0],tmpCRnti[0],msgType[0],rapid[0],ta[0],nrOfRar[0])

    return msg2mpdcch_handled_data1,final_data,title

paa = [['sigNo', '0'], ['header'], ['cellId', '4'], ['sfn', '375'], ['subframeNr', '7'], [], ['transactionNo', '49741'], ['overload', 'false'], ['nrOfSibMsg', '0'], ['nrOfPagingMsg', '0'], ['nrOfComMsg', '0'], ['nrOfRaMsg2Msg', '1'], ['totalNrOfMsg', '1'], ['padding0', '0'], ['msgStructList'], ['msgStructList'], ['msgType', '5'], ['decisionIndex', '0'], ['commonTb'], ['newDataFlag', 'true'], ['tbSizeInBytes', '7'], ['l1Tb'], ['rvIndex', '0'], ['modType', '0'], ['nrOfRateMatchedBits', '0'], ['rmSoftBits', '0'], [], [], ['l1Control'], ['rnti', '902'], ['deltaPsdL1', '0'], ['txScheme', '2'], ['txMode', '-1'], ['nbStartPrb', '7'], ['prbList', '63'], ['ceMode', '0'], ['spare0', '0'], ['blockIndex', '0'], ['startSymbol', '2'], ['spare1', '0'], ['firstSf', '7'], ['ueRsScramblingId', '0'], ['codebookIndex', '256'], ['txPdschSector', '1'], ['antennaPortId', '0'], ['padding0', '0'], [], ['raMsg2Info'], ['nrOfRar', '1'], ['backoffIndex', '0'], ['rar'], ['rar'], ['rapid', '4'], ['ta', '124'], ['ulGrant', '975456'], ['tmpCRnti', '11465'], ['padding0', '0'], [], [], [], [], [], []]
pbb = [['sigNo', '0'], ['header'], ['cellId', '4'], ['sfn', '391'], ['subframeNr', '7'], [], ['transactionNo', '49901'], ['overload', 'false'], ['nrOfSibMsg', '0'], ['nrOfPagingMsg', '0'], ['nrOfComMsg', '0'], ['nrOfRaMsg2Msg', '1'], ['totalNrOfMsg', '1'], ['padding0', '0'], ['msgStructList'], ['msgStructList'], ['msgType', '5'], ['decisionIndex', '0'], ['commonTb'], ['newDataFlag', 'true'], ['tbSizeInBytes', '7'], ['l1Tb'], ['rvIndex', '0'], ['modType', '0'], ['nrOfRateMatchedBits', '0'], ['rmSoftBits', '0'], [], [], ['l1Control'], ['rnti', '1862'], ['deltaPsdL1', '0'], ['txScheme', '2'], ['txMode', '-1'], ['nbStartPrb', '7'], ['prbList', '63'], ['ceMode', '0'], ['spare0', '0'], ['blockIndex', '0'], ['startSymbol', '2'], ['spare1', '0'], ['firstSf', '7'], ['ueRsScramblingId', '0'], ['codebookIndex', '256'], ['txPdschSector', '1'], ['antennaPortId', '0'], ['padding0', '0'], [], ['raMsg2Info'], ['nrOfRar', '1'], ['backoffIndex', '0'], ['rar'], ['rar'], ['rapid', '4'], ['ta', '136'], ['ulGrant', '975456'], ['tmpCRnti', '11467'], ['padding0', '0'], [], [], [], [], [], []]

print msg2PdschHandling(paa)[2]
print msg2PdschHandling(paa)[0]




def remove_empty_in_list(old_list):
    new_list = []
    for element_val in old_list:
        if element_val:
            new_list.append(element_val)
    return new_list

def clean_string(old_string, clean_pattern=re.compile('[\[\]{}<>]+')):
    """
    Remove symbol [ ] ( ) < > , "[ ]" use \ to ensure
    """
    cleaned_string = re.sub(clean_pattern, '', old_string)
    return cleaned_string

def split_string_remove_space(old_string, split_pattern=re.compile(r'[:;,()\s]\s*')):
    """
    Split Line(String) to a list, seperator are " = : ; , \s "
    Remove all empty and space element in List
    """
    split_line = re.split(split_pattern, old_string)
    split_line_no_space = [x for x in split_line if x != ' ']
    split_line_clean = remove_empty_in_list(split_line_no_space)
    return split_line_clean


def readmsgthroughsymbolpreamble(filename, not_incl_columns_list=[], last_position=0, max_line=50, select_pattern=re.compile("assignableBytes"), clean_pattern=re.compile('[\[\]{}()<>]+'), split_pattern=re.compile(r'[:;,\s]\s*')):
    file_obj = open(filename, 'rb')
    file_obj.seek(last_position)
    msg1_pattern = re.compile("UpUlCellPeCiScheduleRaResponseInd")
    # seek(offset[, whence]), whence 0 (begin),1(current position) ,2 (file end), offset could be nagetive value.
    #Generate a new list with selected lines as a new list, each list is a str represents each line

    part_file_lines = []
    for i in range(max_line):
        line_item = file_obj.readline()
        if len(line_item) > 0:
            # Handle idle str with readline method.
            part_file_lines.append(line_item)
        else:
            break

    # Find MSG1 message and corresponding info, store them into a new list
    msg1_info_list = []
    tmp_line_number = 0
    for each_tmp_line in part_file_lines:
        #tmp_line_number is line number, starting from 1
        tmp_line_number += 1
        if re.search(msg1_pattern, each_tmp_line):
            for tmp_ii in range(6):
                if re.search(re.compile("nrOfPreambles [1-9]"), part_file_lines[tmp_line_number + tmp_ii]):
                    tmp_symbol_check = 1
                    each_msg1_ie = []
                    for tmp_i in range(200):
                        if tmp_symbol_check !=0:
                            each_msg1_ie.append(part_file_lines[tmp_line_number + tmp_i])
                            if re.search(re.compile("{"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check += 1
                            if re.search(re.compile("}"), part_file_lines[tmp_line_number + tmp_i]):
                                tmp_symbol_check -= 1
                            #print tmp_symbol_check
                        if tmp_symbol_check == 0:
                            break
                    msg1_info_list.append(each_msg1_ie)

    new_whole_msg = []
    for each_msg1_message in msg1_info_list:
        new_msg1_massage = []
        for each_msg1_message_ie in each_msg1_message:
            cleaned_line = clean_string(each_msg1_message_ie, clean_pattern)
            split_line_clean = split_string_remove_space(cleaned_line, split_pattern)
            new_msg1_massage.append(split_line_clean)
        new_whole_msg.append(new_msg1_massage)

    return new_whole_msg,msg1_info_list

def msg1preambleHandling(msg1preamlelist):
    msg1preamlelist_clean1 = [x for x in msg1preamlelist if x != []]
    msg1preamlelist_clean2 = [x for x in msg1preamlelist_clean1 if len(x) != 1]
    cellId = [99999]
    subframe = [99999]
    sfn = [99999]
    nrOfPreambles = [99999]
    preambleId = [99999]
    timingOffset = [99999]
    preamblePower = [99999]
    prachCeLevel = [99999]

    cellIdIndex = 0
    subframeIndex = 0
    sfnIndex = 0
    nrOfPreamblesIndex = 0
    preambleIdIndex = 0
    timingOffsetIndex = 0
    preamblePowerIndex = 0
    prachCeLevelIndex = 0

    final_data = []
    title = "cellId     sfn        subframe   preambleId prachCeLev timeOffset nrOfPreambles        preamblePower"
    #print title
    for i in msg1preamlelist_clean2:
        if i[0] == "cellId":
            if cellIdIndex == 0:
                cellId[0] = int(i[1])
                cellIdIndex += 1
            else:
                cellId.append(int(i[1]))
            final_data.append(cellId)
        elif i[0] == "subframeRach":
            if subframeIndex == 0:
                subframe[0] = int(i[1])
                subframeIndex += 1
            else:
                subframe.append(int(i[1]))
            final_data.append(subframe)
        elif i[0] == "sfnRach":
            if sfnIndex == 0:
                sfn[0] = int(i[1])
                sfnIndex += 1
            else:
                sfn.append(int(i[1]))
            final_data.append(sfn)
        elif i[0] == "nrOfPreambles":
            if nrOfPreamblesIndex == 0:
                nrOfPreambles[0] = int(i[1])
                nrOfPreamblesIndex += 1
            else:
                nrOfPreambles.append(int(i[1]))
            final_data.append(nrOfPreambles)
        elif i[0] == "preambleId":
            if preambleIdIndex == 0:
                preambleId[0] = int(i[1])
                preambleIdIndex += 1
            else:
                preambleId.append(int(i[1]))
            final_data.append(preambleId)
        elif i[0] == "timingOffset":
            if timingOffsetIndex == 0:
                timingOffset[0] = int(i[1])
                timingOffsetIndex += 1
            else:
                timingOffset.append(int(i[1]))
            final_data.append(timingOffset)
        elif i[0] == "preamblePower":
            if preamblePowerIndex == 0:
                preamblePower[0] = int(i[1])
                preamblePowerIndex += 1
            else:
                preamblePower.append(int(i[1]))
            final_data.append(preamblePower)
        elif i[0] == "prachCeLevel":
            if prachCeLevelIndex == 0:
                prachCeLevel[0] = int(i[1])
                prachCeLevelIndex += 1
            else:
                prachCeLevel.append(int(i[1]))
            final_data.append(prachCeLevel)


    msg1preamble_handled_data1 = "%-10d %-10d %-10d %-10d %-10d %-10d %-20d %-20d" % (cellId[0],sfn[0],subframe[0],preambleId[0],prachCeLevel[0],timingOffset[0],nrOfPreambles[0],preamblePower[0])

    return msg1preamble_handled_data1,final_data,title


new_log_list = readmsgthroughsymbolpreamble("c:/Users/eyulcui/Documents/tmp/Baseband_working_SP2_PRACH_8_MPDCCH_16_repete_celevel1_notworking_try3.raw.dec", select_pattern=re.compile("assignableBytes"), max_line=100000)
print "cellId     sfn        subframe   preambleId prachCeLev timeOffset nrOfPreambles        preamblePower"
for tmp_print in new_log_list[0]:
    print msg1preambleHandling(tmp_print)[0]
    #print tmp_print