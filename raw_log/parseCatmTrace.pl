#!/opt/tools/tools/perl/5.12.2/bin/perl
#
# parseCatmTrace.pl - Parse CAT-M trace file
#
# See more details in man page section at the bottom of this file.
#
# Author: Hugh Arthur
#

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my $script_version      = "0.5";

my $debug               = undef;
my $report              = undef;
my $showSib             = undef;
my $showExtra           = undef;
my $showExtraUL         = undef;
my $skipMpdcch          = undef;
my $skipCch             = undef;
my $skipUe              = undef;
my $skipHarq            = undef;
my $skipHarqFdbk        = undef;
my $skipHarqBufRelease  = undef;
my $showAllUe           = undef;
my $verbose             = undef;
my $tracefile           = undef;
my $dciDecode           = undef;
my %uelist              = ();
my %uelistB             = ();
my $rntiCur             = 0;
my $bbUeRefCur          = 0;

my $linenumber = 0;
my $countCch = 0;
my $countCchSib = 0;
my $countCchPaging = 0;
my $countCchCom = 0;
my $countCchMsg2 = 0;
my $countMpdcch = 0;
my $countUeAlloc = 0;
my $countHarqAlloc = 0;
my $countHarqAllocValid = 0;
my $countHarqFdbk = 0;
my $countHarqFdbkValid = 0;
my $countHarqBufRelease = 0;
my $countDci62 = 0;
my %countHarqfdbk = ();
$countHarqfdbk{0} = 0;
$countHarqfdbk{1} = 0;
$countHarqfdbk{4} = 0;
$countHarqfdbk{5} = 0;

# For progress info
my $start = time;
my $end;
my ($dmin, $dhour, $dday, $dmon, $dyear) = (localtime)[1..5];
my $ddate = sprintf( "%04d-%02d-%02d-%02d:%02d", 1900+$dyear, 1+$dmon, $dday, $dhour, $dmin );
my $chunkend;
my $chunkstart = $start;
my $mainloopstart = $start;
my $unparsedultrace = 0;
my $numfiles = 0;
my $numdots = 10;
my $currDir = `pwd`;
chomp $currDir;
# manually change for extra verbose debugging
my $debug_extra         = undef;
$debug_extra = 1;

my $dci6decode = '/proj/lmr_usr/ehugart/dci6decode';


################################################
#
# Command options
my %optCtl = (
              "help|?"         => sub { usageHelp(0)},
              "usage"          => sub { usageHelp(1)},
              "man"            => sub { usageHelp(2)},
              "debug"          => \$debug,
              "report"         => \$report,
              "verbose"        => \$verbose,
              "showSib"        => \$showSib,
              "showTraces"     => \$showExtra,
              "showUL"         => \$showExtraUL,
              "skipMpdcch"     => \$skipMpdcch,
              "skipCch"        => \$skipCch,
              "skipUeAlloc"    => \$skipUe,
              "skipHarq"       => \$skipHarq,
              "skipHarqFdbk"   => \$skipHarqFdbk,
              "skipHarqRel"    => \$skipHarqBufRelease,
              "showAllUe"      => \$showAllUe,
              "tracefile=s"    => \$tracefile,
              "file=s"         => \$tracefile,
              "dciDecode"      => \$dciDecode,
             );

if (scalar(@ARGV) > 0 && !GetOptions(%optCtl)) {
    die "ERROR: Option parsing failed";
}

if ( $dciDecode && $skipMpdcch ) {
    die "ERROR: dciDecode option is not compatible with skipMpdcch option.";
}

if ( $showSib && $skipCch ) {
    die "ERROR: showSib option is not compatible with skipCch option.";
}

if ( ! $tracefile ) {
    die "ERROR: Must specify decoded trace file to parse";
}

if ( ! -r $tracefile ) {
    die "ERROR: File $tracefile is NOT readable!";
}

#reset numdots
$numdots = 10;
# Start output here since wc can take very long time for very big files
print "CAT-M parser processing file: $tracefile\n";
warn "Counting lines to process ...\n";

my $newfilesize = `wc -l $tracefile`;
my $stepsize = 0;

if($newfilesize =~ /^(\d+).*/)
{
    $newfilesize = $1;
    $stepsize = $1/10
}
my $checksize = $stepsize;
my $filesize += $newfilesize;

warn "Lines to process: $filesize\n";
warn "**********   \n";

sub checkNewUe {
    my ($bbUeRefCur, $rntiCur) = @_;

    # Warn about 0 values due to improper handling of rnti bbUeRef order in messages
    if (($rntiCur == 0) || ($bbUeRefCur == 0)) {
        print "#### WARNING >>>>> rntiCur = $rntiCur bbUeRefCur = $bbUeRefCur\n";
    }

    if ($rntiCur == 65534)
    {
        # Don't count for paging rnti
        print "#### FILTER PAGING RNTI rntiCur = $rntiCur bbUeRefCur = $bbUeRefCur\n" if $debug;
        return "filter";
    }

    if ( ! $uelistB{$bbUeRefCur} ) {
        # initialize all fields for new UEs
        print "#### FOUND NEW UE BBUEREF rnti = $rntiCur bbUeRefCur = $bbUeRefCur\n" if $debug;
        $uelistB{$bbUeRefCur}{"countMpdcch"} = 0;
        $uelistB{$bbUeRefCur}{"countMsg4"} = 0;
        $uelistB{$bbUeRefCur}{"countUeAlloc"} = 0;
        $uelistB{$bbUeRefCur}{"countHarqfdbk"}{"total"} = 0;
        $uelistB{$bbUeRefCur}{"countHarqfdbk"}{"0"} = 0;
        $uelistB{$bbUeRefCur}{"countHarqfdbk"}{"1"} = 0;
        $uelistB{$bbUeRefCur}{"countHarqfdbk"}{"4"} = 0;
        $uelistB{$bbUeRefCur}{"countHarqBufRel"} = 0;
        $uelistB{$bbUeRefCur}{"rnti"} = 0;
    }
    $uelistB{$bbUeRefCur}{"rnti"} = $rntiCur if $rntiCur != 0;

    # TODO: Remove above bbUeRefCur based hash once rest of code
    # like counting Msg4 and UeAlloc etc is updated to use rnti based hash

    if ( ! $uelist{$rntiCur}{$bbUeRefCur} ) {
        print "#### FOUND NEW UE RNTI rnti = $rntiCur bbUeRefCur = $bbUeRefCur\n" if $debug;
        $uelist{$rntiCur}{$bbUeRefCur}{"bbUeRefCount"} = 1;
        $uelist{$rntiCur}{$bbUeRefCur}{"countMpdcch"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countMsg4"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countUeAlloc"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countHarqfdbk"}{"total"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countHarqfdbk"}{"0"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countHarqfdbk"}{"1"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countHarqfdbk"}{"4"} = 0;
        $uelist{$rntiCur}{$bbUeRefCur}{"countHarqBufRel"} = 0;
    }
    else {
        # Count usage of each bbUeRef
        $uelist{$rntiCur}{$bbUeRefCur}{"bbUeRefCount"}++;
    }

    return "ok"

}

sub checkUeCountHarqfdbk {
    my ($bbUeRefCur, $harqfdbk) = @_;

    # Search rnti list for bbueref since rnti is not in message
    foreach my $rnti ( keys %uelist ) {
        print " DEBUG checkUeCountHarqfdbk RNTI $rnti BBUEREF $bbUeRefCur $harqfdbk \n" if $debug;
        if (exists $uelist{$rnti}{$bbUeRefCur}) {
            $uelist{$rnti}{$bbUeRefCur}{"bbUeRefCount"}++;
            $uelist{$rnti}{$bbUeRefCur}{"countHarqfdbk"}{"total"}++;
            $uelist{$rnti}{$bbUeRefCur}{"countHarqfdbk"}{$harqfdbk}++;
        }
    }

}

sub checkUeCountHarqBufRel {
    my ($bbUeRefCur) = @_;

    # Search rnti list for bbueref since rnti is not in message
    foreach my $rnti ( keys %uelist ) {
        print " DEBUG checkUeCountHarqBufRel RNTI $rnti BBUEREF $bbUeRefCur \n" if $debug;
        if (exists $uelist{$rnti}{$bbUeRefCur}) {
            $uelist{$rnti}{$bbUeRefCur}{"bbUeRefCount"}++;
            $uelist{$rnti}{$bbUeRefCur}{"countHarqBufRel"}++;
        }
    }

}

#UpDlMacPeCiMpdcchInd {
#  sigNo 0,
#  header {
#    header {
#      cellId 3,
#      sfn 947,
#      subframeNr 6
#    },
#    totalNrOfSets 1,
#    padding0 0
#  },
#  setList {
#    setList {
#      header {
#        totalNrOfMpdcchDci 1,
#        padding0 0
#      },
#      setConfig {
#        setSize 6,
#        isDistributed 1,
#        setId 92,
#        padding0 5,
#        startSymbol 3,
#        startPrb 1,
#        padding1 29,
#        padding2 13654
#      },
#      mpdcch {
#        mpdcch {
#          rnti 20231,
#          deltaPsd 4096,
#          bbUeRef 50331872,
#          cceIndex 0,
#          nrOfCce 24,
#          nrOfRbaBits 8,
#          startRbaBit 2,
#          rbaBits 301989888,
#          nrOfPayloadBit 21,
#          admissionCtrlWeightAboveThreshold 0,
#          admissionCtrlResourceType 0,
#          seArp 0,
#          nrOfDtx 0,
#          cceAllocType 0,
#          mpdcchSetIndex 1,
#          servCellIndex 0,
#          mpdcchBlockIndex 0,
#          mpdcchCEMode 0,
#          mpdcchFirstSf 9476,
#          dciMsg {
#            dciMsg 47105,
#            dciMsg 0


#UpDlMacPeCiMpdcchInd {
#      cellId 3,
#      sfn 947,
#      subframeNr 6
#        setSize 6,
#        startSymbol 3,
#        startPrb 1,
#          rnti 20231,
#          bbUeRef 50331872,
#          nrOfCce 24,
#          nrOfRbaBits 8,
#          startRbaBit 2,
#          rbaBits 301989888,
#          nrOfPayloadBit 21,
#          dciMsg {
#            dciMsg 47105,
#            dciMsg 0

# Funcition may push multiple MPDCCH signals if dciMsg is not found
sub getMpddchSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    $countMpdcch += 1;

    my $mpdcchSignal = "MpdcchInd      ";
    my $dciMsgPart = 0;
    my $dciMsg1 = "";
    my $dciMsg2 = "";
    my $dciMsgType = "?";
    my $dciNrPayload = 0;
    $rntiCur = 0;
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found MPDCCH $line " if $debug;
        chomp $line;
        if ( $line =~ /UpDlMacPeCiMpdcchInd {/ ) {
            # Found new MPDCCH signal, push previous in complete and start new one
            $mpdcchSignal = $mpdcchSignal . " PARTIAL";
            print "MPDCCH signal $mpdcchSignal \n" if $debug;
            push( @$catmSignalList, $mpdcchSignal );
            $mpdcchSignal = "MpdcchInd      ";
            $countMpdcch += 1;
            $dciMsgType = "";
            $dciMsg1 = "";
            $dciMsg2 = "";
            $dciNrPayload = 0;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " cell $1";
        }
        elsif ( $line =~ /sfn (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " sf $1";
        }
        elsif ( $line =~ /subframeNr (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " $1";
        }
        elsif ( $line =~ /setSize (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " config $1";
        }
        elsif ( $line =~ /setId (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " $1";
        }
        elsif ( $line =~ /startPrb (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " $1";
        }
        elsif ( $line =~ /rnti (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " rnti $1";
            $rntiCur = $1;
        }
        elsif ( $line =~ /bbUeRef (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " bbUe $1";
            $bbUeRefCur = $1;
            if (checkNewUe($bbUeRefCur,$rntiCur) =~ "ok") {
                $uelistB{$bbUeRefCur}{"countMpdcch"} += 1;
                $uelist{$rntiCur}{$bbUeRefCur}{"countMpdcch"} += 1;
            }
        }
        elsif ( $line =~ /nrOfCce (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " nCce $1";
        }
        elsif ( $line =~ /nrOfRbaBits (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " RbaBits $1";
        }
        elsif ( $line =~ /startRbaBit (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " $1";
        }
        elsif ( $line =~ /rbaBits (\d+)/ ) {
            my $hex = sprintf("0x%08X", $1);
            $mpdcchSignal = $mpdcchSignal . " $hex";
        }
        elsif ( $line =~ /nrOfPayloadBit (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " nrOfPayloadBit $1";
            $dciNrPayload = $1;
            # DCI 6-0-A has 20 bits and DCI 6-1-A has 21 bits
            if (($1 == 20) || ($1 == 21)) {
                # Need to decode more to figure out actual 6-x-x
            }
            elsif ($1 == 9) {
                $dciMsgType = "dci62";
                $countDci62 += 1;
            }
        }
        elsif ( $line =~ /mpdcchSetIndex (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " msi $1";
        }
        elsif ( $line =~ /mpdcchBlockIndex (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " mbi $1";
        }
        elsif ( $line =~ /mpdcchFirstSf (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " mfSf $1";
        }
        elsif ( $line =~ /dciMsg {/ ) {
            $mpdcchSignal = $mpdcchSignal . " dciMsg";
        }
        elsif ( $line =~ /dciMsg (\d+)/ ) {
            $mpdcchSignal = $mpdcchSignal . " $1";
            if ($dciMsgPart == 1) {
                $dciMsg2 = $1;
                my $dciFields = "";
                my $dciMsg = (($dciMsg1 << 16) + $dciMsg2);
                my $hex = sprintf("0x%08X", $dciMsg);
                if ($dciNrPayload == 21)
                {
                    # DCI 6-0-A and 6-1-A Common fields
                    my $dciFormatFlag = (($dciMsg >> 31) & 1);
                    my $dciHoppingFlag = (($dciMsg >> 30) & 1);
                    my $dciMcs = (($dciMsg >> 26) & 15);
                    my $dciRep = (($dciMsg >> 24) & 3);
                    my $dciHp = (($dciMsg >> 21) & 7);
                    my $dciNdi = (($dciMsg >> 20) & 1);
                    my $dciRv = (($dciMsg >> 18) & 3);
                    my $dciTpc = (($dciMsg >> 16) & 3);
                    $dciFields = "hop=$dciHoppingFlag mcs=$dciMcs rep=$dciRep hp=$dciHp ndi=$dciNdi rv=$dciRv tpc=$dciTpc";
                    #printf("\n %32b dciFormatFlag %d\n",$dciMsg, $dciFormatFlag);
                    if($dciFormatFlag == 0)
                    {
                        # DCI 6-0-A specific fields
                        $dciMsgType = "60A";
                        my $dciCsi = (($dciMsg >> 15) & 1);
                        my $dciSrs = (($dciMsg >> 14) & 1);
                        my $dciRepetition = (($dciMsg >> 12) & 3);
                        $dciFields = $dciFields . " csi=$dciCsi srs=$dciSrs dcirep=$dciRepetition";
                    }
                    else
                    {
                        # DCI 6-1-A specific fields
                        $dciMsgType = "61A";
                        my $dciSrs = (($dciMsg >> 15) & 1);
                        my $dciHarqAckOffset = (($dciMsg >> 13) & 3);
                        my $dciSfRepetition = (($dciMsg >> 11) & 3);
                        $dciFields = $dciFields . " srs=$dciSrs hacko=$dciHarqAckOffset sfrep=$dciSfRepetition";
                    }
                }
                elsif ($dciNrPayload == 9)
                {
                    # DCI 6-2 paging
                    my $dciPagingDirect = (($dciMsg >> 31) & 1);
                    my $dciMcs = (($dciMsg >> 28) & 7);
                    my $dciRep = (($dciMsg >> 25) & 7);
                    my $dciSfRepetition = (($dciMsg >> 23) & 3);
                    $dciFields = "direct=$dciPagingDirect mcs=$dciMcs rep=$dciRep sfrep=$dciSfRepetition";
                }

                $mpdcchSignal = $mpdcchSignal . " $hex $dciMsgType $dciFields";
                #printf("{6 dciMsg(0x%x) }", $dciMsg);
                print "MPDCCH signal $mpdcchSignal \n" if $debug || $dciDecode;
                my $dci6decodeMsgType = "";
                $dci6decodeMsgType = "62" if $dciMsgType =~ "dci62";
                system("$dci6decode $dciMsg1 $dciMsg2 $dci6decodeMsgType") if $dciDecode;
                return $mpdcchSignal;
            }
            else {
                # wait for second part of dciMsg
                $dciMsgPart = 1;
                $dciMsg1 = $1;
            }
        }
    }
}

#UpDlMacPeCiDlCatmCchAllocInd {
#  sigNo 0,
#  header {
#    cellId 3,
#    sfn 924,
#    subframeNr 4
#  },
#  transactionNo 18211,
#  overload false,
#  nrOfSibMsg 1,
#  nrOfPagingMsg 0,
#  nrOfComMsg 0,
#  nrOfRaMsg2Msg 0,
#  totalNrOfMsg 1,

# Further content for Msg2
#      raMsg2Info {
#        nrOfRar 1,
#        backoffIndex 0,
#        rar {
#          rar {
#            rapid 21,
#            ta 1,
#            ulGrant 983648,
#            tmpCRnti 24879,
#            padding0 0

# Further content for Msg4
#  msgStructList {
#    msgStructList {
#      msgType 4,
#
#      l1Control {
#        rnti 24879,
#        deltaPsdL1 0,
#        txScheme 2,
#        txMode -1,
#        nbStartPrb 7,
#        prbList 3,
#        ceMode 0,
#        spare0 0,
#        blockIndex 0,
#        startSymbol 3,
#        spare1 0,
#        firstSf 8,
#        ueRsScramblingId 0,
#        codebookIndex 256,
#        txPdschSector 1,
#        antennaPortId 0,
#        padding0 0
#      },
#      bbUeRef 797713888


# Funcition may push multiple CchAlloc signals if dciMsg is not found
sub getCatmCchAllocSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    $countCch += 1;

    my $signal = "CatmCchAllocInd";
    my $onlySib = 1;
    my $msg2Found = 0;
    my $msg4Found = 0;
    my $pagingFound = 0;
    $rntiCur = 0;
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found CCH ALLOC $line " if $debug;
        chomp $line;
        if ( $line =~ /UpDlMacPeCiDlCatmCchAllocInd {/ ) {
            # Found new CCH ALLOC signal, push previous in complete and start new one
            $signal = $signal . " PARTIAL";
            if (($onlySib == 0) || ($showSib)) {
                push( @$catmSignalList, $signal );
            }
            else {
                print "Filter " if $debug;
            }
            print "CATMCCHALLOC signal $signal \n" if $debug;
            # Start handling new cchAlloc and assume it will be for sib unless
            $signal = "CatmCchAllocInd";
            $onlySib = 1;
            $countCch += 1;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $signal = $signal . " cell $1";
        }
        elsif ( $line =~ /sfn (\d+)/ ) {
            $signal = $signal . " sf $1";
        }
        elsif ( $line =~ /subframeNr (\d+)/ ) {
            $signal = $signal . " $1";
        }
        elsif ( $line =~ /nrOfSibMsg (\d+)/ ) {
            $signal = $signal . " nrSib $1";
            $countCchSib += $1;
        }
        elsif ( $line =~ /nrOfPagingMsg (\d+)/ ) {
            $signal = $signal . " nrPag $1";
            if ($1 != 0) {
                $onlySib = 0;
                $countCchPaging += $1;
                $pagingFound = 1;
            }
        }
        elsif ( $line =~ /nrOfComMsg (\d+)/ ) {
            $signal = $signal . " nrCom $1";
            if ($1 != 0) {
                $onlySib = 0;
                $countCchCom += $1;
                $msg4Found = 1;
            }
        }
        elsif ( $line =~ /nrOfRaMsg2Msg (\d+)/ ) {
            $signal = $signal . " nrMsg2 $1";
            if ($1 != 0) {
                $onlySib = 0;
                $countCchMsg2 += $1;
                $msg2Found = 1;
            }
        }
        elsif ( $line =~ /nbStartPrb (\d+)/ ) {
            $signal = $signal . " nbPrb $1";
        }
        elsif ( $line =~ /rvIndex (\d+)/ ) {
            $signal = $signal . " rvi $1";
        }
        elsif ( $line =~ /blockIndex (\d+)/ ) {
            $signal = $signal . " bi $1";
        }
        elsif ( $line =~ /firstSf (\d+)/ ) {
            $signal = $signal . " fSf $1";
        }

        # For Sib
        elsif ( $line =~ /siId (\d+)/ ) {
            $signal = $signal . " siId $1";
            if (($onlySib == 0) || ($showSib)) {
                # Now there is more processing of Msg2 and Msg4
                # TODO: Add more Paging processing??
                if (($msg2Found == 0) && ($msg4Found == 0) && ($pagingFound == 0)) {
                    print "CATMCCHALLOC signal $signal \n" if $debug;
                    return $signal;
                }
                else {
                    print "CATMCCHALLOC signal continue Msg2/Msg4/Paging processing \n" if $debug;
                }
            }
            else {
                print "Filter CATMCCHALLOC signal $signal \n" if $debug;
                return "";
            }
        }

        # For CatmCch Msg2
        #            tmpCRnti 24879,
        elsif (($msg2Found == 1) && ($line =~ /tmpCRnti (\d+)/ )) {
            $signal = $signal . " tmpCRnti $1";
            print "CATMCCHALLOC signal $signal \n" if $debug;
            return $signal;
        }
        # For CatmCch Com/Msg4
        elsif (($msg4Found == 1) && ($line =~ /rnti (\d+)/ )) {
            if ($1 =~ 65535) {
                print "Ignore rnti for sib" if $debug && $showSib;
            }
            else {
                $signal = $signal . " rnti $1";
                $rntiCur = $1;
            }
        }
        elsif (($msg4Found == 1) && ($line =~ /bbUeRef (\d+)/ )) {
            $signal = $signal . " bbUe $1";
            $bbUeRefCur = $1;
            if (checkNewUe($bbUeRefCur,$rntiCur) =~ "ok") {
                $uelistB{$bbUeRefCur}{"countMsg4"} += 1;
                $uelist{$rntiCur}{$bbUeRefCur}{"countMsg4"} += 1;
            }
            print "CATMCCHALLOC signal $signal \n" if $debug;
            return $signal;
        }

        # For CatmCch Paging
        elsif (($pagingFound == 1) && ($line =~ /pageRef (\d+)/ )) {
            $signal = $signal . " pageRef $1";
            print "CATMCCHALLOC signal $signal \n" if $debug;
            return $signal;
        }

        elsif ( $line =~ /tbSizeInBytes (\d+)/ ) {
            $signal = $signal . " tbSizeInBytes $1";
        }
    }
}

#UpDlMacPeCiDlCatmUeAllocInd {
#  sigNo 0,
#  header {
#    cellId 3,
#    sfn 109,
#    subframeNr 8
#  },
#  transactionNo 20305,
#  nrOfUe 1,
#  ueAlloc {
#    ueAlloc {
#      bbUeRef 50331872,
#      l1Control {
#        rnti 20231,
#        deltaPsdL1 0,
#        txScheme 2,
#        txMode -1,
#        nbStartPrb 1,
#        prbList 3,
#        ceMode 0,
#        spare0 0,
#        blockIndex 0,
#        startSymbol 3,
#        spare1 0,
#        firstSf 8,
#        ueRsScramblingId 0,
#        codebookIndex 256,
#        txPdschSector 1,
#        antennaPortId 0,
#        padding0 0
#      },
#      tbAlloc {
#        tbIndex 0,
#        padding0 0,
#        commonTb {
#          newDataFlag true,
#          tbSizeInBytes 7,
#          l1Tb {
#            rvIndex 0,
#            modType 0,
#            nrOfRateMatchedBits 0,
#            rmSoftBits 0
#          }
#        },
#        macTb {
#          dlHarqProcessId 0,
#          nrOfMacCtrlElem 0,
#          macCeAlloc {
#            macCeAlloc {
#              lcid 0,
#              padding0 0,
#              data {
#                data 0,
#                data 0,
#                data 0
#              },
#              padding1 0
#            },
# ...
#        rlcTb {
#          nrOfBearer 1,
#          padding0 0,
#          bearerAlloc {
#            bearerAlloc {
#              bbBearerRef 50331872,
#              lcid 1,
#              rbScheduledSizeInBytes 7
#            },
#            bearerAlloc {
#              bbBearerRef 0,
#              lcid 0,
#              rbScheduledSizeInBytes 0
#            }
#          }
#        }
#      },
#      decisionIndex 0,

# Function may push multiple UeAlloc signals if dciMsg is not found
sub getCatmUeAllocSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    my $signal = "CatmUeAllocInd ";
    $rntiCur = 0;
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found UE ALLOC $line " if $debug;
        chomp $line;
        if ( $line =~ /UpDlMacPeCiDlCatmUeAllocInd {/ ) {
            # Found new UE ALLOC signal, push previous in complete and start new one
            $signal = $signal . " PARTIAL";
            push( @$catmSignalList, $signal );
            print "CATMUEALLOC signal $signal \n" if $debug;
            # Start handling new cchAlloc and assume it will be for sib unless
            $signal = "CatmUeAllocInd ";
            $countUeAlloc += 1;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $signal = $signal . " cell $1";
        }
        elsif ( $line =~ /sfn (\d+)/ ) {
            $signal = $signal . " sf $1";
        }
        elsif ( $line =~ /subframeNr (\d+)/ ) {
            $signal = $signal . " $1";
        }
        elsif ( $line =~ /nrOfUe (\d+)/ ) {
            $signal = $signal . " nrUe $1";
        }
        elsif ( $line =~ /bbUeRef (\d+)/ ) {
            $signal = $signal . " bbUe $1";
            $bbUeRefCur = $1;
        }
        elsif ( $line =~ /rnti (\d+)/ ) {
            $signal = $signal . " rnti $1";
            $rntiCur = $1;
            if (checkNewUe($bbUeRefCur,$rntiCur) =~ "ok") {
                $uelistB{$bbUeRefCur}{"countUeAlloc"} += 1;
                $uelist{$rntiCur}{$bbUeRefCur}{"countUeAlloc"} += 1;
            }
        }
        elsif ( $line =~ /nbStartPrb (\d+)/ ) {
            $signal = $signal . " nbPrb $1";
        }
        elsif ( $line =~ /rvIndex (\d+)/ ) {
            $signal = $signal . " rvi $1";
        }
        elsif ( $line =~ /blockIndex (\d+)/ ) {
            $signal = $signal . " bi $1";
        }
        elsif ( $line =~ /firstSf (\d+)/ ) {
            $signal = $signal . " fSf $1";
        }
        elsif ( $line =~ /tbSizeInBytes (\d+)/ ) {
            $signal = $signal . " tbSizeInBytes $1";
        }
        elsif ( $line =~ /dlHarqProcessId (\d+)/ ) {
            $signal = $signal . " hpId $1";
        }
        elsif ( $line =~ /bbBearerRef (\d+)/ ) {
            $signal = $signal . " bbBearer $1";
        }
        elsif ( $line =~ /rbScheduledSizeInBytes (\d+)/ ) {
            $signal = $signal . " rbBytes $1";
        }
        elsif ( $line =~ /decisionIndex (\d+)/ ) {
            $signal = $signal . " decision $1";
            print "CATMUEALLOC signal $signal \n" if $debug;
            return $signal;
        }
    }
}

#UpUlMacPeCiDlHarqAllocInd {
#  sigNo 65536,
#  header {
#    cellId 3,
#    sfn 104,
#    subFrameNo 1
#  },
#  dlSfn 103,
#  dlSubframeNr 7,
#  isCatm 1,
#  padding0 0,
#  noOfHarqAllocations 1,
#  harqAllocList {
#    harqAllocList {
#      bbUeRef 59367648,
#      crnti 20231,
#      rxPucchSector 0,
#      caHarqFeedbackMode 0,
#      sCellsConfigured 0,
#      padding0 0,
#      freqOffEstPusch 0,
#      nReps 1,
#      subframeCnt 1,
#      padding1 0,
#      padding2 0,
#      tddDlHarqBundlingInfo {
#        nBundled 0,
#        dlMaxNrOfBundledSubframes 0,
#        bundlingSubframeIndex 0,
#        anMode 0,
#        multiplexingAmbiguityMode 0
#      },
#      carrierHarqInfo {
#        carrierHarqInfo {
#          ElibBbBaseCommonPucchResource '00 00'H,
#          valid 1,
#          dlHarqProcessId 0,
#          nrOfTb 1,
#          maxNrOfTbs 1,
#          isPCell 1,
#          isCceIndex 1,
#          padding0 0
#        },
#        carrierHarqInfo {
#          ElibBbBaseCommonPucchResource '00 00'H,
#          valid 0,
#          dlHarqProcessId 0,
#          nrOfTb 0,
#          maxNrOfTbs 0,
#          isPCell 0,
#          isCceIndex 0,
#          padding0 0
#        },

# Function may push multiple HarqAlloc signals if valid dlHarqProcessId is not found
sub getCatmHarqAllocSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    my $signal = "HarqAllocInd   ";
    my $carrierHarqInfoFound = 0;
    $rntiCur = 0;
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found HARQ ALLOC $line " if $debug;
        chomp $line;
        if ( $line =~ /UpUlMacPeCiDlHarqAllocInd {/ ) {
            # Found new HARQ ALLOC signal, push previous in complete and start new one
            $signal = $signal . " PARTIAL";
            push( @$catmSignalList, $signal );
            print "CATMHARQALLOC signal $signal \n" if $debug;
            # Start handling new HarqAlloc
            $signal = "HarqAllocInd    ";
            $carrierHarqInfoFound = 0;
            $countHarqAlloc += 1;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $signal = $signal . " cell $1";
        }
        elsif ( $line =~ /sfn (\d+)/ ) {
            $signal = $signal . " sf $1";
        }
        elsif ( $line =~ /subFrameNo (\d+)/ ) {
            $signal = $signal . " $1";
        }
        elsif ( $line =~ /dlSfn (\d+)/ ) {
            $signal = $signal . " dlsf $1";
        }
        elsif ( $line =~ /dlSubframeNr (\d+)/ ) {
            $signal = $signal . " $1";
        }
        elsif ( $line =~ /noOfHarqAllocations (\d+)/ ) {
            if ($1 == 0)
            {
                # return empty since no harq alloc
                return "";
            }
            $signal = $signal . " nrAlloc $1";
        }
        elsif ( $line =~ /isCatm (\d+),/ ) {
            if ($1 == 0)
            {
                # return empty since not cat-m harq alloc
                return "";
            }
            # nothing to save here since only interested in cat-m anyway
        }
        elsif ( $line =~ /bbUeRef (\d+)/ ) {
            $signal = $signal . " bbUe $1";
            $bbUeRefCur = $1;
        }
        elsif ( $line =~ /crnti (\d+)/ ) {
            $signal = $signal . " rnti $1";
            $rntiCur = $1;
            if (checkNewUe($bbUeRefCur,$rntiCur) =~ "ok") {
                $uelistB{$bbUeRefCur}{"countHarqAlloc"} += 1;
                $uelist{$rntiCur}{$bbUeRefCur}{"countHarqAlloc"} += 1;
            }
        }
        elsif ( $line =~ /carrierHarqInfo {/ ) {
            $carrierHarqInfoFound = 1;
            #print "     carrierHarqInfo  Found\n";
        }
        elsif ( $line =~ /valid 1,/ ) {
            #print "     valid 1  Found\n";
            if ($carrierHarqInfoFound == 1) {
                if ( my $line2 = <$TRACEFILE> ) {
                    $linenumber++;
                    if ( $line2 =~ /dlHarqProcessId (\d+)/ ) {
                        $signal = $signal . " hpId $1";
                        # end of cat-m harq since only 1 expected now
                        $countHarqAllocValid++;
                        return $signal;
                    }
                    else {
                        return "";
                    }
                }
                else {
                    return "";
                }
            }
        }
    }
}

sub getHarqInd
{
    my ($hardInd) = @_;
    if ($hardInd == 0)
    {
        return " NACK";
    }
    elsif ($hardInd == 1)
    {
        return " ACK ";
    }
    elsif ($hardInd == 4)
    {
        return " DTX ";
    }
    return " ?   ";
}

# LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND
#  UpUlMacPeCiUlL1Harqfdbk2DlInd {
#
#UpUlMacPeCiUlL1Harqfdbk2DlInd {
#  sigNo 134218752,
#  header {
#    cellId 8,
#    sfn 63,
#    subFrameNo 8
#  },
#  nrOfPuschReports 0,
#  nrOfPucchReports 1,
#  puschHarqReportList ''H,
#  pucchHarqReportList {
#    pucchHarqReportList {
#      cfrCarrierNo 0,
#      puschPucchHarqAmbiguity 0,
#      bbUeRef 134218752,
#      dlHarqInfo {
#        dlHarqInfo {
#          dlHarqValid 1,
#          dlHarqProcessId 0,
#          nrOfTb 1,
#          srPresent 0,
#          anMode 0,
#          detectedHarqIndication 4
#        },
#        dlHarqInfo {
#          dlHarqValid 0,
# Function may push multiple Harq feedback signals if valid dlHarqValid is not found
sub getCatmHarqfdbkSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    my $signal = "Harqfdbk 2DL   ";
    my $puschReportFound = 0;
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found HARQ FDBK  $line " if $debug;
        chomp $line;
        if ( $line =~ /UpUlMacPeCiUlL1Harqfdbk2DlInd {/ ) {
            # Found new HARQ FDBK  signal, push previous in complete and start new one
            $signal = $signal . " PARTIAL";
            push( @$catmSignalList, $signal );
            print "CATMHARQFDBK signal $signal \n" if $debug;
            # Start handling new Harqfdbk
            $signal = "Harqfdbk 2DL  ";
            $countHarqFdbk++;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $signal = $signal . " cell $1";
        }
        elsif ( $line =~ /sfn (\d+)/ ) {
            $signal = $signal . " sf $1";
        }
        elsif ( $line =~ /subFrameNo (\d+)/ ) {
            $signal = $signal . " $1";
        }
        elsif ( $line =~ /nrOfPuschReports (\d+)/ ) {
            if ($1 > 0 )
            {
                print " DEBUG getCatmHarqfdbkSignal found PuschReport\n" if $debug;
                my $puschReportFound = 1;
                # TODO handle nrOfPuschReports ???
            }
            $signal = $signal . " nrPuschRep $1";
        }
        elsif ( $line =~ /nrOfPucchReports (\d+)/ ) {
            if (($1 == 0) && ($puschReportFound == 0))
            {
                # return empty since no harq pucch or pusch report
                return "";
            }
            $signal = $signal . " nrPucchRep $1";
        }
        elsif ( $line =~ /bbUeRef (\d+)/ ) {
            $signal = $signal . " bbUe $1";
            $bbUeRefCur = $1;
            return "" if !$uelistB{$bbUeRefCur}; # Not CAT-M if we don't know it already
            $uelistB{$bbUeRefCur}{"countHarqfdbk"}{"total"} += 1;
        }
        elsif ( $line =~ /dlHarqValid 1,/ ) {
            # print "     dlHarqValid 1  Found\n";
            my $dlHarqInfoLines = 6;
            while (defined (my $line2 = <$TRACEFILE>) && ($dlHarqInfoLines-- > 0)) {
                # print "     dlHarqValid 1  $line2\n";
                $linenumber++;
                if ( $line2 =~ /dlHarqProcessId (\d+)/ ) {
                    $signal = $signal . " hpId $1";
                }
                elsif ( $line2 =~ /detectedHarqIndication (\d+)/ ) {
                    my $harqInd = $1;
                    $signal = $signal . " harq $harqInd" . getHarqInd($harqInd);
                    $countHarqfdbk{$harqInd} += 1;
                    $uelistB{$bbUeRefCur}{"countHarqfdbk"}{$harqInd} += 1;
                    checkUeCountHarqfdbk($bbUeRefCur, $harqInd);
                }
            }
            # end of cat-m harq fdbk since only 1 expected now
            $countHarqFdbkValid++;
            return $signal;
        }
    }
}

# Function may push multiple Harq buffer release signals if valid dlHarqStatus is not found
sub getCatmHarqBufReleaseSignal {
    my ($TRACEFILE, $catmSignalList) = @_;

    my $signal = "HarqBufRelease ";
    $bbUeRefCur = 0;

    while ( my $line = <$TRACEFILE> ) {
        $linenumber++;
        print "Found HARQ BUFREL $line " if $debug;
        chomp $line;
        if ( $line =~ /UpDlMacPeCiDlHarqBuffReleaseInd {/ ) {
            # Found new HARQ BUFREL  signal, push previous in complete and start new one
            $signal = $signal . " PARTIAL";
            push( @$catmSignalList, $signal );
            print "CATMHARQBUFREL signal $signal \n" if $debug;
            # Start handling new Harq buf release
            $signal = "HarqBufRelease ";
            $countHarqBufRelease++;
        }
        elsif ( $line =~ /cellId (\d+)/ ) {
            $signal = $signal . " cell $1";
        }
        elsif ( $line =~ /isCom (true|false)/ ) {
            $signal = $signal . " com $1";
        }
        elsif ( $line =~ /nrOfUe (\d+)/ ) {
            if ($1 == 0)
            {
                # return empty since no UEs
                # TODO handle nrOfPuschReports ???
                return "";
            }
            $signal = $signal . " nrOfUe $1";
        }
        elsif ( $line =~ /bbUeRef (\d+)/ ) {
            $signal = $signal . " bbUe $1";
            $bbUeRefCur = $1;
            return "" if !$uelistB{$bbUeRefCur}; # Not CAT-M if we don't know it already
            $uelistB{$bbUeRefCur}{"countHarqBufRel"} += 1;
            checkUeCountHarqBufRel($bbUeRefCur);
        }
        elsif ( $line =~ /dlHarqProcessId (\d+),/ ) {
            # print "     dlHarqProcessId 1  Found\n";
            $signal = $signal . " hpId $1";
            my $dlHarqInfoLines = 4;
            while (defined (my $line2 = <$TRACEFILE>) && ($dlHarqInfoLines-- > 0)) {
                # print "     dlHarqProcessId  $line2\n";
                $linenumber++;
                if ( $line2 =~ /harqStatus (\d+)/ ) {
                    $signal = $signal . " harqStatus $1";
                }
                elsif ( $line2 =~ /cellNo (\d+)/ ) {
                    $signal = $signal . " cellNo $1";
                }
            }
            # end of cat-m harq fdbk since only 1 expected now
            return $signal;
        }
    }
}

sub printProgress {
    if ($linenumber > $checksize) {
        #print "Number of lines parsed   = $linenumber\n";
        $chunkend = time;
        #print "chunkstart $chunkstart\n";
        #print "chunkend $chunkend\n";
#        if ($chunkend ==  $chunkstart) {
#            # to prevent divide by zero for small files
#            $chunkend += 1;
#        }
#        my $linespersecond = sprintf("%d",$stepsize/($chunkend - $chunkstart));
#        my $tdifference = sprintf("%.3f", $chunkend - $chunkstart);
#        $chunkstart  = $chunkend;

        $numdots--;
        my $dots = sprintf("*" x $numdots);
        my $numspace = 10-$numdots;
        my $spaces = sprintf("-" x $numspace);
#        ($dmin, $dhour, $dday, $dmon, $dyear) = (localtime)[1..5];
#        my $ddate = sprintf( "%04d-%02d-%02d-%02d:%02d", 1900+$dyear, 1+$dmon, $dday, $dhour, $dmin );

#        warn "$dots$spaces        $linenumber of $filesize  $tdifference s  $linespersecond Lines/second $ddate\n";
        warn "$dots$spaces        $linenumber of $filesize \n";
        $checksize = $linenumber + $stepsize;
    }
}

# TODO: Add these signals
#
# LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_DL_IND
#   UpUlMacPeCiUlL1Measrprt2DlInd
#    nrOfPucchReports 1,

sub saveSignal{
    my ($catmSignal, $catmSignalList) = @_;

    if ($debug) {
        #print "DEBUG $#$catmSignalList saveSignal $catmSignal\n" if $catmSignal;
        #print "DEBUG $#$catmSignalList saveSignal @$catmSignalList[$#$catmSignalList] previous\n" if $#$catmSignalList >= 0;
    }

    if (! $catmSignal) {
        # print "DEBUG no signal to save\n" if $debug;
        return;
    }
    elsif ($#$catmSignalList < 0) {
        print "DEBUG signal list is empty\n" if $debug;
    }
    elsif ("$catmSignal" =~ "@$catmSignalList[$#$catmSignalList]") {
        #print "DEBUG signal is same as previous.\n" if $debug;
        return;
    }

    push( @$catmSignalList, $catmSignal );

}

sub getCatmSignals {
    my ($tracefile) = @_;

    my $catmSignal;
    my @catmSignalList;

    open( my $IN, "<", $tracefile ) || die "ERROR: Cannot open $tracefile";
    while ( my $line = <$IN> ) {
        $linenumber++;
        chomp $line;
        #print "DEBUG $line \n" if $debug_extra;
        if ( $line =~ /UpDlMacPeCiMpdcchInd {/ ) {
            if ($skipMpdcch) {
                print "Filter MPDCCH $line  \n" if $debug;
            }
            else {
                print "Found MPDCCH $line \n" if $debug;
                $catmSignal = getMpddchSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ /UpDlMacPeCiDlCatmCchAllocInd {/ ) {
            if ($skipCch) {
                print "Filter CCH $line  \n" if $debug;
            }
            else {
                print "Found CCH $line \n" if $debug;
                $catmSignal = getCatmCchAllocSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ /UpDlMacPeCiDlCatmUeAllocInd {/ ) {
            $countUeAlloc++;
            if ($skipUe) {
                print "Filter UE $line  \n" if $debug;
            }
            else {
                print "Found UE $line \n" if $debug;
                $catmSignal = getCatmUeAllocSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ /UpUlMacPeCiDlHarqAllocInd {/ ) {
            $countHarqAlloc++;
            if ($skipHarq) {
                print "Filter HARQ ALLOC $line  \n" if $debug;
            }
            else {
                print "Found HARQ ALLOC $line \n" if $debug;
                $catmSignal = getCatmHarqAllocSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ /UpUlMacPeCiUlL1Harqfdbk2DlInd {/ ) {
            $countHarqFdbk++;
            if (($skipHarqFdbk) || ($skipHarq)) {
                print "Filter HARQ FDBK $line  \n" if $debug;
            }
            else {
                print "Found HARQ FDBK $line \n" if $debug;
                $catmSignal = getCatmHarqfdbkSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ /UpDlMacPeCiDlHarqBuffReleaseInd {/ ) {
            $countHarqBufRelease++;
            if (($skipHarqBufRelease) || ($skipHarq)) {
                print "Filter HARQ BUFREL $line  \n" if $debug;
            }
            else {
                print "Found HARQ BUFREL $line \n" if $debug;
                $catmSignal = getCatmHarqBufReleaseSignal($IN , \@catmSignalList);
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        # Extra things DL
        if ( $line =~ / (0x\w+)=.bfn.(\d+)\, sfn.(\d+). sf.(\d+).*(UPCDL.2418).* cellId\=(\d+).* tbs\=(\d+) mcs\=(\d+).*nrOfPrbsPerTb\=(\d+)/ ) {
            if ($showExtra) {
                print "Found UPCDL.2418 \n" if $debug;
                $catmSignal = "$5      cell $6 sf $3 $4 MSG2 DB tbs $7 mcs $8 prbs $9 $1 bfn $2";
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ / (0x\w+)=.bfn.(\d+)\, sfn.(\d+). sf.(\d+).*(UPCDL.2507).* cellId\=(\d+).* tbs\=(\d+) mcs\=(\d+).*nrOfPrbsPerTb\=(\d+)/ ) {
            if ($showExtra) {
                print "Found UPCDL.2507 \n" if $debug;
                $catmSignal = "$5      cell $6 sf $3 $4 MSG4 DB tbs $7 mcs $8 prbs $9 $1 bfn $2";
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        if ( $line =~ / (0x\w+)=.bfn.(\d+)\, sfn.(\d+). sf.(\d+).*(UPCDL.2536).* cellId\=(\d+).* tbs\=(\d+) mcs\=(\d+).*nrOfPrbsPerTb\=(\d+)/ ) {
            if ($showExtra) {
                print "Found UPCDL.2536 \n" if $debug;
                $catmSignal = "$5      cell $6 sf $3 $4 UE DB tbs $7 mcs $8 prbs $9 $1 bfn $2";
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }
        # Extra things UL
        if ( $line =~ / (0x\w+)=.bfn.(\d+)\, sfn.(\d+). sf.(\d+).*(UPCUL.1758).* cellid\=(\d+) ulSfn\=(\d+) ulSubframe\=(\d+).*nrOfSortedSes=1/ ) {
            if (($showExtra) || ($showExtraUL)) {
                print "Found UPCUL.1758 \n" if $debug;
                $catmSignal = "$5      cell $6 sf $3 $4 sf $7 $8 $1 bfn $2";
                saveSignal($catmSignal,  \@catmSignalList);
            }
        }

        printProgress();
    }
    close($IN);

    return @catmSignalList;
}


# main

my $username = $ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
if($username ne "ehugart")
{
    my $userfile = "/proj/lmr_usr/ehugart/.parseCatmTraceUserlist";
    if(open USERFILE, '>>'.$userfile){
        print USERFILE "$username $ddate $script_version $currDir $tracefile \n";
        close USERFILE;
    }
}

my @catmSignalList = getCatmSignals($tracefile);

if ($verbose) {
    print "CAT-M signals found:";
    if ($#catmSignalList <= 0) {
        print " NONE \n"
    }
    else {
        print "\n";
        print " mpdcch filtered\n" if $skipMpdcch;
        print " cch only with sib filtered (use -showsib to disable filter)\n" if ! $showSib;
        print " cch all filtered\n" if $skipCch;
        print " ue alloc all filtered\n" if $skipUe;
        print " harq all filtered\n" if $skipHarq;
        print " harq feedback all filtered\n" if $skipHarqFdbk;
        print " harq buf release all filtered\n" if $skipHarqBufRelease;
        print "\n" , Dumper \@catmSignalList;
    }
}

my $numberOfUeB =  scalar keys %uelistB;
my $numberOfUeBWithData = 0;
my $numberOfUeBWithMsg4 = 0;

if ( $numberOfUeB > 0 ) {
    if (($showAllUe) || ($verbose)) {
        print "\nCATM UEs BY BbUeRef:\n";
    }
    else {
        print "\nCATM UEs BY BbUeRef with Msg4 or Data:\n";
    }


    foreach my $ue ( keys %uelistB ) {
        if (( $uelistB{$ue}{"countUeAlloc"} > 0 ) || ( $uelistB{$ue}{"countMsg4"} > 0 )) {
            if ( $uelistB{$ue}{"countUeAlloc"} > 0 ) {
                $numberOfUeBWithData++;
            }
            if ( $uelistB{$ue}{"countMsg4"} > 0 ) {
                $numberOfUeBWithMsg4++;
            }
            if ($verbose) {
                # Dump UE info for UEs with data verbose option
                print "BbUeRef $ue ", Dumper \$uelistB{$ue}
            }
            else {
                # Print just BbUeRef for UEs with data for showAllUe without verbose option
                my $rnti = $uelistB{$ue}{"rnti"};
                print "BbUeRef $ue rnti $rnti\n";
            }
        }
        else {
            # Dump UE info for UEs without data for when both showAllUe and verbose option
            print "BbUeRef $ue " , Dumper \$uelistB{$ue} if $showAllUe && $verbose;
        }
    }
    print "NONE\n" if ($numberOfUeBWithMsg4 + $numberOfUeBWithData == 0);
}

my $numberOfUe =  scalar keys %uelist;
my $numberOfUeWithData = 0;
my $numberOfUeWithMsg4 = 0;

if ( $numberOfUe > 0 ) {
    if (($showAllUe) || ($verbose)) {
        print "\nCATM UE stats BY RNTI:\n";
    }

    foreach my $rnti ( keys %uelist ) {
        my $currentRntiPrinted = 0;
        #print "DEBUG DUMP RNTI $rnti printed $currentRntiPrinted ...\n" if $debug;
        foreach my $bbUeRef ( keys %{ $uelist{$rnti} } ) {
            #print "DEBUG DUMP RNTI $rnti BBUEREF $bbUeRef  printed $currentRntiPrinted ...\n" if $debug;
            if ((( $uelist{$rnti}{$bbUeRef}{"countUeAlloc"} > 0 ) || ( $uelist{$rnti}{$bbUeRef}{"countMsg4"} > 0 )) &&
                ($currentRntiPrinted == 0)) {
                if ( $uelist{$rnti}{$bbUeRef}{"countUeAlloc"} > 0 ) {
                    $numberOfUeWithData++;
                }
                if ( $uelist{$rnti}{$bbUeRef}{"countMsg4"} > 0 ) {
                    $numberOfUeWithMsg4++;
                }
                if ($verbose) {
                    # Dump UE info for UEs with data verbose option
                    print "rnti $rnti ", Dumper \$uelist{$rnti};
                    $currentRntiPrinted = 1;
                }
                elsif ( $showAllUe ) {
                    # Print just BbUeRef for UEs with data for showAllUe without verbose option
                    #my $rnti = $uelist{$ue}{"rnti"};
                    #print "rnti $ue rnti $rnti\n";
                    print "rnti $rnti ", Dumper \$uelist{$rnti};
                    $currentRntiPrinted = 1;
                }
            }
            elsif ($currentRntiPrinted == 0) {
                # Dump UE info for UEs without data for when both showAllUe and verbose option
                if ($showAllUe && $verbose) {
                    print "rnti $rnti " , Dumper \$uelist{$rnti} if $showAllUe && $verbose;
                    $currentRntiPrinted = 1;
                }
            }
        }
    }
    print "NONE\n" if !$showAllUe && ($numberOfUeWithMsg4 + $numberOfUeWithData == 0) && $verbose;
}


print "\nSummary:\n";
print "Number of lines parsed              = $linenumber\n";
print "Number of CATM RNTIs                = $numberOfUe\n";
print "Number of CATM BbUeRefs             = $numberOfUeB\n";
print "Number of CATM BbUeRefs w Msg4      = $numberOfUeBWithMsg4\n";
print "Number of CATM BbUeRefs w UeAlloc   = $numberOfUeBWithData\n";
print "Number of CATM MPDCCH               = $countMpdcch\n";
print "Number of CATM MPDCCH DCI 6-2       = $countDci62\n";
print "Number of CATM CCH                  = $countCch\n";
print "Number of CATM CCH SIB              = $countCchSib\n";
print "Number of CATM CCH Paging           = $countCchPaging\n";
print "Number of CATM CCH Msg2             = $countCchMsg2\n";
print "Number of CATM CCH Com/Msg4         = $countCchCom\n";
print "Number of CATM Ue Alloc             = $countUeAlloc\n";
print "Number of Harq Alloc                = $countHarqAlloc\n";
print "Number of CATM Harq Alloc Valid     = $countHarqAllocValid\n";
print "Number of Harq Feedback             = $countHarqFdbk\n";
print "Number of CATM Harq Feedback 0 NACK = $countHarqfdbk{0}\n";
print "Number of CATM Harq Feedback 1 ACK  = $countHarqfdbk{1}\n";
print "Number of CATM Harq Feedback 4 DTX  = $countHarqfdbk{4}\n";
print "Number of CATM Harq Feedback 5 UNKN = $countHarqfdbk{5}\n";
print "Number of Harq Buf Release          = $countHarqBufRelease\n";
exit 0;

sub usageHelp {

    my ($help_verbose) = @_;
    print "Version $script_version\n";
    pod2usage(-verbose => $help_verbose);

}

__END__

=head1 NAME

parseCatmTraces.pl - Parse CAT-M trace file (mostly DL for now)

=head1 SYNOPSIS

 parseCatmTraces.pl -f filename [-skipcch] [-skipue] [-skipmpdcch]
                                [-dci] [-showsib] [-showtrace] [-verbose] [-debug]
 parseCatmTraces.pl -help
 parseCatmTraces.pl -usage
 parseCatmTraces.pl -man

 See -usage and -man output for more details including useful signals to trace.

=head1 OPTIONS

=over

=item B<-f <filename>>

Required parameter to specify the decoded eNB trace file to parse.

=item B<-debug>

Display additional debugging information.

=item B<-dci>

Decode DciMsg found in CAT-M Mpdcch signals.

=item B<-showAllUe>

Dump per UE info.
Without -verbose, only displays info for UEs with Msg4 or UeAlloc signals.

=item B<-showsib>

Display info about any CAT-M CchAlloc signals that only contain a sib.
Default does not display sib only CchAlloc signals because there are so many.

=item B<-showtraces>

When -showtraces is used with -verbose, also include traces like Msg2 UPCDL.2418, Msg4 UPCDL.2509, etc.
Default does not display traces in output.

=item B<-skipcch>

Do not display info about any CAT-M CchAlloc signals.

=item B<-skipmpdcch>

Do not display info about any CAT-M Mpdcch signals.

=item B<-skipuealloc>

Do not display info about any CAT-M UeAlloc signals.

=item B<-skipharq>

Do not display info about any CAT-M Harq signals.

=item B<-skipharqfdbk>

Do not display info about CAT-M Harq feedback signals.

=item B<-skipharqbufrel>

Do not display info about CAT-M Harq buffer release signals.

=item B<-verbose>

Display info about each CAT-M signal.

=back

=head1 DESCRIPTION

Parser currently only extracts info for these CAT-M signals:
   MPDCCH                UpDlMacPeCiMpdcchInd
   CATM_CCH_ALLOC        UpDlMacPeCiDlCatmCchAllocInd
   CATM_UE_ALLOC         UpDlMacPeCiDlCatmUeAllocInd
   HARQ_ALLOC            UpUlMacPeCiDlHarqAllocInd
   HARQFDBK              UpUlMacPeCiUlL1Harqfdbk2DlInd
   HARQ_BUFF_REL         UpDlMacPeCiDlHarqBuffReleaseInd

Traces required for fully functionality:
   mtd peek -ta dlMacPeBl -sig LPP_UP_DLMACPE_CI_MPDCCH_IND -dir INCOMING
   mtd peek -ta dlMacPeBl -sig LPP_UP_DLMACPE_CI_DL_CATM_CCH_ALLOC_IND
   mtd peek -ta dlMacCeBl -signal LPP_UP_DLMACPE_CI_DL_CATM_UE_ALLOC_IND
   mtd peek -ta ulL1PeBl -signal LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND -dir INCOMING
   mtd peek -ta ulMacPeBl -sig LPP_UP_ULMACPE_CI_DL_HARQ_ALLOC_IND -dir INCOMING
   mtd peek -ta dlMacCeBl -sig LPP_UP_DLMACPE_CI_DL_HARQ_BUFF_RELEASE_IND -dir OUTGOING

Examples:

 parseCatmTraces.pl -file /tmp/bb-16Nov.log.dec
 parseCatmTraces.pl -file /tmp/bb-16Nov.log.dec  -v
 parseCatmTraces.pl -f    /tmp/bb-16Nov.log.dec  -v -showsib
 parseCatmTraces.pl -f    /tmp/bb-16Nov.log.dec  -showallue
 parseCatmTraces.pl -f    /tmp/bb-16Nov.log.dec  -dci
 parseCatmTraces.pl -f         bb-16Nov.log.dec  -dci -v
 parseCatmTraces.pl -f         bb-16Nov.log.dec  -skipue -skipharq -v


