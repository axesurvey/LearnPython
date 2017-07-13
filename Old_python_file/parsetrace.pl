#!/usr/bin/perl
#
#
#This script is originated from Ying Yin in Nanjing ENC. With the great skill
#and idea he has, this core/soul part of this script can work well to store the
#signals in hash_table->hash_table(arrays).
#I only made ugly changes based on his excellent work.
# todo:
# Identify some potential issues:
# 1) Different signals have different, and all these signals are under the change.
# It seems the best way is to do such message parse automatically according to *.sig file's signal definition. But in order to output the signal in a more readble way,
# some manual explanation is also needed. 
# 2) It's hard to use a common state machine to parse all these signals.
# Different signals have quite different meaning to users. The state machine has
# to be per signal. How about generating these state machine from these *.sig
# files, then decode the baseband trace according to these state machines?
# 3) For some signals, it might be possible that just print them out directly
# one by one according to the original format as a defult behavior.
# 4) Different UP versions have different signal formats. Thus, it makes it hard
# to follow the changes in all these signals.

use strict;
use warnings;
use Carp;
use Data::Dumper;

sub parseStruct;

$Data::Dumper::Indent = 1;


my $ctx = {
};

my @signals = ();
my @traces = (); #record different trace object trace.

# store and statistic all signals
my %signalTable=(
  #<key>: signalName => <value>: numberOfSignals
);
my %traceTable=(
  #<key>: traceName => <value>: numberOfTraces
);

my $TRUE = 1;
my $FALSE = 0;

my $previousSfn = 0;
my $accuSfn = 0;

# declare the signal number(key) should be tracked. the value is used to
# identify whether the first line(format) of that signal has been printed out or
# not.
my %outputSignalTable = (
  "LPP_UP_DLMACPE_CI_PDCCH_IND" => "$TRUE",
  "LPP_UP_ULL1PE_EI_ALLOCATION_IND" => {
                                         Pusch => "$TRUE",
                                         Pucch => "$TRUE",
                                       },
  "LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_UL_IND" => {
                                                  SrsReports => "$TRUE",
                                                  RxPowerPerPrb => "$TRUE",
                                                  PuschReports => "$TRUE",
                                                },
  "LPP_UP_ULMACPE_CI_UL_MAC_CTRL_INFO_IND" => "$TRUE",
  "LPP_UP_ULMACPE_CI_UL_UE_ALLOC_IND" => "$TRUE",
  "LPP_UP_ULCELLPE_CI_CELL_STATUS_REPORT_IND" => "$TRUE",
  "LPP_UP_DLMACPE_CI_DL_UE_ALLOC_IND" => "$TRUE",
  "UPC_DLMACCE_FI_UL_PDCCH_REQ" => "$TRUE",
  "LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_DL_IND" => {
                                                  Pusch => "$TRUE",
                                                  Pucch => "$TRUE",
                                                  SectorPower => "$TRUE",
                                                },
  "LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND" => "$TRUE",
  "LPP_UP_ULMACPE_CI_DL_HARQ_ALLOC_IND" => "$TRUE",
);

#print "ARGV = @ARGV \n";

if ((@ARGV != 1) || ($ARGV[0] =~ m/help/))
{
  #print "Usage: parsetrace.pl < <inputFileName> <inputFileName> \n";
  print "Usage: $0 <inputFileName> \n";
  exit 1;
}
my $inputFile = $ARGV[0];
$_ = $inputFile;
s#.*/##g;
my $inputFileName = $_;

my $currentDir=`pwd`;
chomp($currentDir);

my $outputFile = "$currentDir/$inputFileName";
#print "outputFile name is $outputFile \n";

open (INPUT_FILE, "<$inputFile") || die "Sorry, open file $inputFile failed!\n";
#======================filter baseband signal first===================
print "\nFind below baseband signals :\n";
while (<INPUT_FILE>) {
  chomp;

  # in below if condition, also trace one unique trace: 0x4dc343c4.
  if (/^\[(?<date>[^\s]+)\s+(?<time>[^\s]+)\]\s+(?<originalBfnSfBf>\w+).*
       bfn:(?<bfn>\d+),\s+
       sfn:(?<sfn>\d+),\s+
       sf:(?<sf>[^,]+),\s+
       bf:(?<bf>\d+).*
       BIN_[^\s]+\s+:\s+(?<SIGNAME>[^\s]+)/x) {

       # the corresponding signal counter++. 
       if (exists($signalTable{$+{SIGNAME}}))
       {
          $signalTable{$+{SIGNAME}}++;
       }
       else
       {
         $signalTable{$+{SIGNAME}} = 1;
         print "$+{SIGNAME} ";

         if (!exists($outputSignalTable{$+{SIGNAME}}))
         {
           print ": no further parse. \n";
         }
         else
         {
           #print ": further parse supported already! \n";
           print "\n";
         }
       }

       # only check need output signal to save some time. 
       if (!exists($outputSignalTable{$+{SIGNAME}}))
       {
         next;
       }

       # put the sigSeqNo/Counter and originalBfnSfBf into the meta data.
       $ctx->{meta} = {
         line => $.,
         sigSeqNo => $signalTable{$+{SIGNAME}},
         date => "["."$+{date}"."]",
         time => "["."$+{time}"."]",
         originalBfnSfBf => $+{originalBfnSfBf},
         bfn => $+{bfn},
         sfn => $+{sfn},
         sf => $+{sf},
         bf => $+{bf},
         SIGNAME => $+{SIGNAME},
       };

       ## make date and timee also be included.
       #my $date = $+{date};
       #my $time = $+{time};
       ##operate date
       #$_ = $date;
       #s/^\[//;
       #$ctx->{meta}->{date} = $_;
       ##operate time
       #$_ = $time;
       #s/]$//;
       #$ctx->{meta}->{time} = $_;


       my ($name, $o) = parseStruct;
       $ctx->{state} = 0;
       $ctx->{meta}->{signame} = $name;
       
       my $sig = {
         meta => $ctx->{meta},
         data => $o,
       };

       # for debug purpose:
       #print(Dumper($sig));
       
       push @signals, $sig;
  }
}

# print the number of all kinds of signals.
print "\nTotal baseband signals:\n";
#print Dumper(\%signalTable);
while (my ($key, $value) = each %signalTable) {
    print "$key => $value times\n";
  }
print "\n\n";


# output baseband  signal 
while (my ($outputSigName, $outputPrintFlag) = each %outputSignalTable) 
{
  #initial flags which symbols whether the corresponding file is opened or not.
  my $OUTPUT_FLAG = $FALSE;
  my $PUCCH_FLAG = $FALSE;
  my $PUSCH_FLAG = $FALSE;
  my $SRS_FLAG = $FALSE;
  my $POWER_FLAG = $FALSE;
  #my $PDCCH_FLAG = $FALSE;
  #my $PDSCH_FLAG = $FALSE;

  $previousSfn = 0;
  $accuSfn = 0;

    # Example
  for my $sig (@signals) {
    my $m = $sig->{meta};
    my $SIGNAME = $m->{SIGNAME};

    # comment this LPP_UP_DLMACPE_CI_PDCCH_IND handling block.
    if ($SIGNAME eq $outputSigName)
    {
      #====================================================
      if ($SIGNAME eq 'LPP_UP_DLMACPE_CI_PDCCH_IND') 
      {
        my $o = $sig->{data};

        if (($o->{header}->{totalNrOfDci} > 0) || ($o->{header}->{totalNrOfEpdcchDci} > 0))
        {

          my $pdcch = defined($o->{pdcch}) && ref($o->{pdcch}) eq 'HASH' ? $o->{pdcch}->{pdcch} : undef;
          if(defined($pdcch)) {

            ref($pdcch) eq 'ARRAY' or $pdcch = [$pdcch];

            for (@$pdcch) {
              # print the header as the top line for excel file.
              if ($outputSignalTable{$SIGNAME} eq "$TRUE")
              {
                open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
                $OUTPUT_FLAG = $TRUE;
                printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNr,totalNrOfDci,totalNrOfEpdcchDci";

                printf OUTPUT_FILE ",rnti,deltaPsd,bbUeRef,bbUeRefInHex,cceIndex,nrOfCce,nrOfRbaBits,startRbaBit,rbaBits";
                printf OUTPUT_FILE ",nrOfPayloadBit,admissionCtrlWeightAboveThreshold,admissionCtrlResourceType,seArp,nrOfDtx,cceAllocType,cceAllocTypeE";

                my $dciMsg = 
                  defined($_->{dciMsg}) && ref($_->{dciMsg}) eq 'HASH' ? $_->{dciMsg}->{dciMsg} : undef;
                if(defined($dciMsg)) {
                  ref($dciMsg) eq 'ARRAY' or $dciMsg = [$dciMsg];

                  my $count = 0;
                  for (@$dciMsg) {
                    printf OUTPUT_FILE ",dciMsg[$count]";
                    $count ++;
                  }
                }

                printf OUTPUT_FILE ",ePdcchSetIndex,servCellIndex";

                #printf OUTPUT_FILE ",dciMsg1,dciMsg2";
                printf OUTPUT_FILE "\n";

                $outputSignalTable{$SIGNAME} = "$FALSE";
              }

            } #for (@$pdcch) 

            # print the message fields
            for (@$pdcch) {
              my $tti = calculateTti($o->{header}->{header}->{sfn},$o->{header}->{header}->{subframeNr});
              printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{header}->{cellId},$o->{header}->{header}->{sfn},$o->{header}->{header}->{subframeNr},$o->{header}->{totalNrOfDci},$o->{header}->{totalNrOfEpdcchDci}";

              printf OUTPUT_FILE ",$_->{rnti},$_->{deltaPsd},$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{cceIndex},$_->{nrOfCce},$_->{nrOfRbaBits},$_->{startRbaBit},$_->{rbaBits}";
              printf OUTPUT_FILE ",$_->{nrOfPayloadBit},$_->{admissionCtrlWeightAboveThreshold},$_->{admissionCtrlResourceType},$_->{seArp},$_->{nrOfDtx},$_->{cceAllocType},${\mapCceAllocType($_->{cceAllocType})}";
              #for the internal dciMsg structure // here it has some issue for the dci msg for it has two files with the same name.
              #my $dci =defined($o->{pdcch}) && ref($o->{pdcch}) eq 'HASH' ? $o->{pdcch}->{pdcch} : undef; 
              my $dciMsg = 
                defined($_->{dciMsg}) && ref($_->{dciMsg}) eq 'HASH' ? $_->{dciMsg}->{dciMsg} : undef;
              if(defined($dciMsg)) {
                ref($dciMsg) eq 'ARRAY' or $dciMsg = [$dciMsg];

                my $count = 0;
                for (@$dciMsg) {
                  printf OUTPUT_FILE ",$_";
                  $count ++;
                }
              }
             
              printf OUTPUT_FILE ",$_->{ePdcchSetIndex},$_->{servCellIndex}";
              printf OUTPUT_FILE "\n";
            }
          }

        } #$o->{header}->{totalNrOfDci} > 0) || ($o->{header}->{totalNrOfEpdcchDci} > 0)
      } #if ($SIGNAME eq 'LPP_UP_DLMACPE_CI_PDCCH_IND')

      #===================================================
      # LPP_UP_ULMACPE_CI_UL_UE_ALLOC_IND 
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_UE_ALLOC_IND') 
      {
        my $o = $sig->{data};
        # print the header as the top line for excel file only when the first
        # signal appears.
        if ($outputSignalTable{$SIGNAME} eq "$TRUE")
        {
          open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
          $OUTPUT_FLAG = $TRUE;
          printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNo";
          printf OUTPUT_FILE ",noOfUeAllocations,noOfOnlyScellScheduledUes";


          printf OUTPUT_FILE ",clientRef,clientRefInHex,crnti,raType";
          printf OUTPUT_FILE ",ulHarqProcessId,rvIdx,newDataFlag,qm,tbs,prbListStart,prbListEnd,prbListStart2,prbListEnd2";
          #deep array again.
          printf OUTPUT_FILE ",cfrExpected,cfrExpected,cfrExpected";

          printf OUTPUT_FILE ",rxPuschSector,servCellIndex";
          printf OUTPUT_FILE "\n";

          $outputSignalTable{$SIGNAME} = "$FALSE";
        }

        if ($o->{noOfUeAllocations} == 0)
        {
          next;
        }
        my $ueAllocList = 
          defined($o->{ueAllocList}) && ref($o->{ueAllocList}) eq 'HASH' ? $o->{ueAllocList}->{ueAllocList} : undef;
        if(defined($ueAllocList)) {
          ref($ueAllocList) eq 'ARRAY' or $ueAllocList = [$ueAllocList];

          # print the message fields
          for (@$ueAllocList) {
            my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
            printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";
            printf OUTPUT_FILE ",$o->{noOfUeAllocations},$o->{noOfOnlyScellScheduledUes}";


            printf OUTPUT_FILE ",$_->{common}->{clientRef},${\convertToHex($_->{common}->{clientRef})},$_->{common}->{crnti},$_->{common}->{raType}";
            printf OUTPUT_FILE ",$_->{l1}->{ulHarqProcessId},$_->{l1}->{rvIdx},$_->{l1}->{newDataFlag},$_->{l1}->{qm},$_->{l1}->{tbs},$_->{l1}->{prbListStart},$_->{l1}->{prbListEnd},$_->{l1}->{prbListStart2},$_->{l1}->{prbListEnd2}";

            #my $cfrInfo = 
              #defined($o->{ueAllocList}->{ueAllocList}->{l1}->{cfrInfo}) && ref($o->{ueAllocList}->{ueAllocList}->{l1}->{cfrInfo}) eq 'HASH' ? $o->{ueAllocList}->{ueAllocList}->{l1}->{cfrInfo}->{cfrInfo} : undef;
            my $cfrInfo = 
              defined($_->{l1}->{cfrInfo}) && ref($_->{l1}->{cfrInfo}) eq 'HASH' ? $_->{l1}->{cfrInfo}->{cfrInfo} : undef;
            if (defined($cfrInfo))
            {
              ref($cfrInfo) eq 'ARRAY' or $cfrInfo = [$cfrInfo];
              for (@$cfrInfo) {
                printf OUTPUT_FILE ",$_->{cfrExpected}";
              }
            }

            printf OUTPUT_FILE ",$_->{l1}->{rxPuschSector},$_->{servCellIndex}";
            printf OUTPUT_FILE "\n";
          }


          #Try to implement another way to go through all the key->value pair.
          #Because only the last value is a number, only the last key is
          #printed. Use non-DiGui method, it is very hard to print it, because I
          #don't know the exact deepth of this structure.
        }

      } #if ($SIGNAME eq 'LPP_UP_ULL1PE_EI_ALLOCATION_IND')




      #===================================================
      # LPP_UP_ULL1PE_EI_ALLOCATION_IND
      if ($SIGNAME eq 'LPP_UP_ULL1PE_EI_ALLOCATION_IND') 
      {
        my $o = $sig->{data};

        if ($o->{noOfPuschAllocations} > 0)
        {

          my $ulL1PuschAllocationStructList = 
            defined($o->{ulL1PuschAllocationStructList}) && ref($o->{ulL1PuschAllocationStructList}) eq 'HASH' ? $o->{ulL1PuschAllocationStructList}->{ulL1PuschAllocationStructList} : undef;
          if(defined($ulL1PuschAllocationStructList)) {
            ref($ulL1PuschAllocationStructList) eq 'ARRAY' or $ulL1PuschAllocationStructList = [$ulL1PuschAllocationStructList];

          # print the header as the top line for excel file only when the first
          # signal appears.
          if ($outputSignalTable{$SIGNAME}->{Pusch} eq "$TRUE")
          {
            open (PUSCH_FILE, ">$outputFile.$outputSigName.PUSCH.csv") || die "Sorry, create $outputSigName  output file failed!\n";
            $PUSCH_FLAG = $TRUE;


            my $printTopLine = $TRUE;
            for (@$ulL1PuschAllocationStructList) 
            {
              if ($printTopLine != $TRUE )
              {
                next;
              }
              printf PUSCH_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNo";
              printf PUSCH_FILE ",noOfPuschAllocations";

              printf PUSCH_FILE ",clientRef,clientRefInHex,crnti,raType";
              printf PUSCH_FILE ",ulHarqProcessId,newDataFlag,tbs,prbListStart,prbListEnd,prbListStart2,prbListEnd2";

              #deep array again.
              #printf PUSCH_FILE ",cfrExpected,cfrExpected,cfrExpected";
              my $cfrInfo = 
              defined($_->{l1}->{cfrInfo}) && ref($_->{l1}->{cfrInfo}) eq 'HASH' ? $_->{l1}->{cfrInfo}->{cfrInfo} : undef;
              if (defined($cfrInfo))
              {
                ref($cfrInfo) eq 'ARRAY' or $cfrInfo = [$cfrInfo];

                my $count = 0;
                for (@$cfrInfo) {
                  printf PUSCH_FILE ",cfrInfo[$count]";
                  printf PUSCH_FILE ",ri,riBitWidth,cfrLength,cfrFormat,cfrValid,cfrExpected,cfrCrcFlag,dlBandwidth";
                  $count++;
                }
              }
             
              printf PUSCH_FILE ",rxPuschSector,servCellIndex";
              printf PUSCH_FILE "\n";
              $outputSignalTable{$SIGNAME}->{Pusch} = "$FALSE";

              $printTopLine = $FALSE;
            
                #Try to implement another way to go through all the key->value pair.
                #Because only the last value is a number, only the last key is
                #printed. Use non-DiGui method, it is very hard to print it, because I
                #don't know the exact deepth of this structure.
              }


            } # for (@$ulL1PuschAllocationStructList) 

          }


            # print the message fields
            for (@$ulL1PuschAllocationStructList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf PUSCH_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";
              printf PUSCH_FILE ",$o->{noOfPuschAllocations}";

              printf PUSCH_FILE ",$_->{common}->{clientRef},${\convertToHex($_->{common}->{clientRef})},$_->{common}->{crnti},$_->{common}->{raType}";
              printf PUSCH_FILE ",$_->{l1}->{ulHarqProcessId},$_->{l1}->{newDataFlag},$_->{l1}->{tbs},$_->{l1}->{prbListStart},$_->{l1}->{prbListEnd},$_->{l1}->{prbListStart2},$_->{l1}->{prbListEnd2}";

              #my $cfrInfo = 
                #defined($o->{ulL1PuschAllocationStructList}->{ulL1PuschAllocationStructList}->{l1}->{cfrInfo}) && ref($o->{ulL1PuschAllocationStructList}->{ulL1PuschAllocationStructList}->{l1}->{cfrInfo}) eq 'HASH' ? $o->{ulL1PuschAllocationStructList}->{ulL1PuschAllocationStructList}->{l1}->{cfrInfo}->{cfrInfo} : undef;
              my $cfrInfo = 
                defined($_->{l1}->{cfrInfo}) && ref($_->{l1}->{cfrInfo}) eq 'HASH' ? $_->{l1}->{cfrInfo}->{cfrInfo} : undef;
              if (defined($cfrInfo))
              {
                ref($cfrInfo) eq 'ARRAY' or $cfrInfo = [$cfrInfo];
                my $count = 0;
                for (@$cfrInfo) {
                  printf PUSCH_FILE ",cfrInfo[$count]";
                  printf PUSCH_FILE ",$_->{ri},$_->{riBitWidth},$_->{cfrLength},$_->{cfrFormat},$_->{cfrValid},$_->{cfrExpected},$_->{cfrCrcFlag},$_->{dlBandwidth}";
                  $count++;
                }
              }

              printf PUSCH_FILE ",$_->{l1}->{rxPuschSector},$_->{servCellIndex}";
              printf PUSCH_FILE "\n";
            }


            #Try to implement another way to go through all the key->value pair.
            #Because only the last value is a number, only the last key is
            #printed. Use non-DiGui method, it is very hard to print it, because I
            #don't know the exact deepth of this structure.
          
        } #if ($o->{noOfPuschAllocations} > 0)

        if ($o->{noOfPucchAllocations} > 0)
        {

          my $ulL1PucchAllocationStructList = 
            defined($o->{ulL1PucchAllocationStructList}) && ref($o->{ulL1PucchAllocationStructList}) eq 'HASH' ? $o->{ulL1PucchAllocationStructList}->{ulL1PucchAllocationStructList} : undef;
          if(defined($ulL1PucchAllocationStructList)) {
            ref($ulL1PucchAllocationStructList) eq 'ARRAY' or $ulL1PucchAllocationStructList = [$ulL1PucchAllocationStructList];

          # print the header as the top line for excel file only when the first
          # signal appears.
          if ($outputSignalTable{$SIGNAME}->{Pucch} eq "$TRUE")
          {
            open (PUCCH_FILE, ">$outputFile.$outputSigName.PUCCH.csv") || die "Sorry, create $outputSigName  output file failed!\n";
            $PUCCH_FLAG = $TRUE;

            my $printTopLine = $TRUE;
            for (@$ulL1PucchAllocationStructList) 
            {
              if ($printTopLine != $TRUE )
              {
                next;
              }
              printf PUCCH_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNo";
              printf PUCCH_FILE ",noOfPucchAllocations";

              printf PUCCH_FILE ",clientRef,clientRefInHex,crnti,raType";

              printf PUCCH_FILE ",cfrInfo";
              printf PUCCH_FILE ",ri,riBitWidth,cfrLength,cfrFormat,cfrValid,cfrExpected,cfrCrcFlag,dlBandwidth";
              #deep array again.
              my $dlHarqAllocInfo = 
              defined($_->{dlHarqAllocInfo}) && ref($_->{dlHarqAllocInfo}) eq 'HASH' ? $_->{dlHarqAllocInfo}->{dlHarqAllocInfo} : undef;
              if (defined($dlHarqAllocInfo))
              {
                ref($dlHarqAllocInfo) eq 'ARRAY' or $dlHarqAllocInfo = [$dlHarqAllocInfo];

                my $count = 0;
                for (@$dlHarqAllocInfo) {
                  printf PUCCH_FILE ",dlHarqAllocInfo[$count]";
                  printf PUCCH_FILE ",dlHarqIndExpected,nrOfTb,nrOfHarqBits,dlHarqProcessId,dlSubframeSchedInd,isCatm";
                  $count++;
                }
              }
             
              printf PUCCH_FILE ",tddDlHarqBundling";
              printf PUCCH_FILE ",nBundled,dlMaxNrOfBundledSubframes,bundlingSubframeIndex,anMode,multiplexingAmbiguityMode";

              printf PUCCH_FILE ",cceIdx,cceIdx1";
              printf PUCCH_FILE ",rxPucchSector,srOrCfrPucchResource,srExpected,cfrCarrierNo,caPucchResource,caPucchResourceType,puschPucchHarqAmbiguity";
              printf PUCCH_FILE "\n";

              $outputSignalTable{$SIGNAME}->{Pucch} = "$FALSE";

              $printTopLine = $FALSE;
            
                #Try to implement another way to go through all the key->value pair.
                #Because only the last value is a number, only the last key is
                #printed. Use non-DiGui method, it is very hard to print it, because I
                #don't know the exact deepth of this structure.
              }


            } # for (@$ulL1PucchAllocationStructList) 


          }


            # print the message fields
            for (@$ulL1PucchAllocationStructList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf PUCCH_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";
              printf PUCCH_FILE ",$o->{noOfPucchAllocations}";

              printf PUCCH_FILE ",$_->{common}->{clientRef},${\convertToHex($_->{common}->{clientRef})},$_->{common}->{crnti},$_->{common}->{raType}";

              printf PUCCH_FILE ",cfrInfo";
              printf PUCCH_FILE ",$_->{cfrInfo}->{ri},$_->{cfrInfo}->{riBitWidth},$_->{cfrInfo}->{cfrLength},$_->{cfrInfo}->{cfrFormat},$_->{cfrInfo}->{cfrValid},$_->{cfrInfo}->{cfrExpected},$_->{cfrInfo}->{cfrCrcFlag},$_->{cfrInfo}->{dlBandwidth}";

              my $dlHarqAllocInfo = 
                defined($_->{dlHarqAllocInfo}) && ref($_->{dlHarqAllocInfo}) eq 'HASH' ? $_->{dlHarqAllocInfo}->{dlHarqAllocInfo} : undef;
              if (defined($dlHarqAllocInfo))
              {
                ref($dlHarqAllocInfo) eq 'ARRAY' or $dlHarqAllocInfo = [$dlHarqAllocInfo];
                my $count = 0;
                for (@$dlHarqAllocInfo) {
                  printf PUCCH_FILE ",dlHarqAllocInfo[$count]";
                  printf PUCCH_FILE ",$_->{dlHarqIndExpected},$_->{nrOfTb},$_->{nrOfHarqBits},$_->{dlHarqProcessId},$_->{dlSubframeSchedInd},$_->{isCatm}";
                  $count++;
                }
              }

              printf PUCCH_FILE ",tddDlHarqBundling";
              printf PUCCH_FILE ",$_->{tddDlHarqBundling}->{nBundled},$_->{tddDlHarqBundling}->{dlMaxNrOfBundledSubframes},$_->{tddDlHarqBundling}->{bundlingSubframeIndex},$_->{tddDlHarqBundling}->{anMode},$_->{tddDlHarqBundling}->{multiplexingAmbiguityMode}";

              printf PUCCH_FILE ",$_->{cceIdx},$_->{cceIdx1}";
              printf PUCCH_FILE ",$_->{rxPucchSector},$_->{srOrCfrPucchResource},$_->{srExpected},$_->{cfrCarrierNo},$_->{caPucchResource},$_->{caPucchResourceType},$_->{puschPucchHarqAmbiguity}";

              printf PUCCH_FILE "\n";
            }


            #Try to implement another way to go through all the key->value pair.
            #Because only the last value is a number, only the last key is
            #printed. Use non-DiGui method, it is very hard to print it, because I
            #don't know the exact deepth of this structure.
          
        } #if ($o->{noOfPucchAllocations} > 0)

      } #if ($SIGNAME eq 'LPP_UP_ULL1PE_EI_ALLOCATION_IND')


      
      # LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_UL_IND
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_UL_IND') 
      {

        my $o = $sig->{data};

        if ($o->{nrOfSrsReports} > 0)
        {
          my $srsRxPowerReportList = defined($o->{srsRxPowerReportList}) && ref($o->{srsRxPowerReportList}) eq 'HASH' ? $o->{srsRxPowerReportList}->{srsRxPowerReportList} : undef;
          if(defined($srsRxPowerReportList)) {
            ref($srsRxPowerReportList) eq 'ARRAY' or $srsRxPowerReportList = [$srsRxPowerReportList];

            # print the header as the top line for excel file.
            if ($outputSignalTable{$SIGNAME}->{SrsReports} eq "$TRUE")
            {
              open (SRS_FILE, ">$outputFile.$outputSigName.SrsReports.csv") || die "Sorry, create $outputSigName  output file failed!\n";
              $SRS_FLAG = $TRUE;
              printf SRS_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
              printf SRS_FILE ",cellId,sfn,subFrameNo,nrOfSrsReports";
              printf SRS_FILE ",bbUeRef,bbUeRefInHex";
              printf SRS_FILE ",prbListStart,prbListEnd"; 

              printf SRS_FILE ",rxPower";
              for (my $i = 0; $i <= 99; $i++)
              {
                print SRS_FILE ",prb[$i]";
              }
              printf SRS_FILE "\n";
              $outputSignalTable{$SIGNAME}->{SrsReports} = "$FALSE";
            }

            # print the message fields
            for (@$srsRxPowerReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf SRS_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf SRS_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfSrsReports}";
              printf SRS_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})}";
              printf SRS_FILE ",$_->{prbListStart},$_->{prbListEnd}";
              printf SRS_FILE ",rxPower";

              my $prbListStart = $_->{prbListStart};
              my $prbListEnd = $_->{prbListEnd};

              if ($prbListStart <= $prbListEnd)
              {
                my $totalNumOfPrb = 100;
                my $i = 0;
                my $srsRxPowerReport = $_;
                while ($i < $totalNumOfPrb)
                {
                  if (($i >= $prbListStart) && ($i <= $prbListEnd))
                  {
                    my $rxPower = 
                    defined($srsRxPowerReport->{rxPower}) && ref($srsRxPowerReport->{rxPower}) eq 'HASH' ? $srsRxPowerReport->{rxPower}->{rxPower} : undef;
                    if (defined($rxPower))
                    {
                      ref($rxPower) eq 'ARRAY' or $rxPower = [$rxPower];
                      for (@$rxPower)
                      {
                        print SRS_FILE ",$_";
                        $i++;
                      }
                    }
                  }
                  else
                  {
                    printf SRS_FILE ",n/a";
                    $i ++;
                  }
                }
              }
              else
              {
                print "Error: uplink no continuous PRB found \n";
                #exit 1;
              }
              printf SRS_FILE "\n";
            }
          }

        }# nrOfSrsReports > 0

        if ($o->{nrOfRxPowerPerPrb} > 0)
        {
          my $puschRxPowerPerPrbList = defined($o->{puschRxPowerPerPrbList}) && ref($o->{puschRxPowerPerPrbList}) eq 'HASH' ? $o->{puschRxPowerPerPrbList}->{puschRxPowerPerPrbList} : undef;
          if(defined($puschRxPowerPerPrbList)) {
            ref($puschRxPowerPerPrbList) eq 'ARRAY' or $puschRxPowerPerPrbList = [$puschRxPowerPerPrbList];

            # print the header as the top line for excel file.
            if ($outputSignalTable{$SIGNAME}->{RxPowerPerPrb} eq "$TRUE")
            {
              open (POWER_FILE, ">$outputFile.$outputSigName.RxPowerPerPrb.csv") || die "Sorry, create $outputSigName  output file failed!\n";
              $POWER_FLAG = $TRUE;
              printf POWER_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
              printf POWER_FILE ",cellId,sfn,subFrameNo,nrOfRxPowerPerPrb";
              printf POWER_FILE ",puschRxPowerPerPrbList";
              for (my $i = 0; $i <= 99; $i++)
              {
                print POWER_FILE ",prb[$i]";
              }
              printf POWER_FILE "\n";
              $outputSignalTable{$SIGNAME}->{RxPowerPerPrb} = "$FALSE";
            }

            # print the message fields
            my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
            printf POWER_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
            printf POWER_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfRxPowerPerPrb}";
            printf POWER_FILE ",puschRxPowerPerPrbList";

            my $numOfPrb = 0;
            my $totalNumOfPrb = 100;
            for (@$puschRxPowerPerPrbList) {
              printf POWER_FILE ",$_";
              $numOfPrb ++;
            }
            while($numOfPrb < $totalNumOfPrb)
            {
              printf POWER_FILE ",n/a"; 
              $numOfPrb++
            }
            printf POWER_FILE "\n";
          }
          #else
          #{
            #print "Not defined, please check \n\n";
          #}
        }# nrOfRxPowerPerPrb > 0

        if ($o->{nrOfPuschReports} > 0)
        {
          my $puschReportList = defined($o->{puschReportList}) && ref($o->{puschReportList}) eq 'HASH' ? $o->{puschReportList}->{puschReportList} : undef;
          if(defined($puschReportList)) {
            ref($puschReportList) eq 'ARRAY' or $puschReportList = [$puschReportList];

            # print the header as the top line for excel file.
            if ($outputSignalTable{$SIGNAME}->{PuschReports} eq "$TRUE")
            {
              open (PUSCH_FILE, ">$outputFile.$outputSigName.PuschReports.csv") || die "Sorry, create $outputSigName  output file failed!\n";
              $PUSCH_FLAG = $TRUE;

              my $printTopLine = $TRUE;


              for (@$puschReportList)
              {
                if ($printTopLine != $TRUE )
                {
                  next;
                }
                printf PUSCH_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
                printf PUSCH_FILE ",cellId,sfn,subFrameNo,nrOfPuschReports";
                printf PUSCH_FILE ",bbUeRef,bbUeRefInHex,isDtx,muIndex";
                printf PUSCH_FILE ",rxPower,prbListStart,prbListEnd,prbListStart2,prbListEnd2,rxPowerReport,sinr";
                printf PUSCH_FILE ",sectorMeas,sinrOfPrimarySector";

                my $sectorMeas = $_->{sectorMeas};
                my $meas = 
                  defined($sectorMeas->{meas}) && ref($sectorMeas->{meas}) eq 'HASH' ? $sectorMeas->{meas}->{meas} : undef;
                if(defined($meas)) {
                  ref($meas) eq 'ARRAY' or $meas = [$meas];
                  my $count = 0;
                  for (@$meas) {
                    printf PUSCH_FILE ",meas[$count]";
                    printf PUSCH_FILE ",sectorCarrierFroId,rxPower"; 
                    $count ++;
                  }
                }

                printf PUSCH_FILE ",servCellIndex,feedbackRef";
                printf PUSCH_FILE ",ulcaSchedInfo";
                my $ulcaSchedInfo = $_->{ulCaSchedInfo};
                my $carrierSchedInfo = 
                  defined($ulcaSchedInfo->{carrierSchedInfo}) && ref($ulcaSchedInfo->{carrierSchedInfo}) eq 'HASH' ? $ulcaSchedInfo->{carrierSchedInfo}->{carrierSchedInfo} : undef;
                if(defined($carrierSchedInfo)) {
                  ref($carrierSchedInfo) eq 'ARRAY' or $carrierSchedInfo = [$carrierSchedInfo];
                  my $count = 0;
                  for (@$carrierSchedInfo) {
                    printf PUSCH_FILE ",carrierSchedInfo[$count]";
                    printf PUSCH_FILE ",isScheduled,duId,cellId";
                    $count ++;
                  }
                }

                printf PUSCH_FILE "\n";
                $outputSignalTable{$SIGNAME}->{PuschReports} = "$FALSE";
                $printTopLine = $FALSE;

              } #for (@$puschReportList) to print the top line.

            } # print the header as the top line for excel file.

            # print the message fields
            for (@$puschReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf PUSCH_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf PUSCH_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfPuschReports}";
              printf PUSCH_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{isDtx}->{isDtx},$_->{muIndex}";
              printf PUSCH_FILE ",rxPower,$_->{rxPower}->{prbListStart},$_->{rxPower}->{prbListEnd},$_->{rxPower}->{prbListStart2},$_->{rxPower}->{prbListEnd2},$_->{rxPower}->{rxPowerReport},$_->{rxPower}->{sinr}";
              printf PUSCH_FILE ",sectorMeas,$_->{sectorMeas}->{sinrOfPrimarySector}"; 

              my $meas = 
                defined($_->{sectorMeas}->{meas}) && ref($_->{sectorMeas}->{meas}) eq 'HASH' ? $_->{sectorMeas}->{meas}->{meas} : undef;
              if(defined($meas)) {
                ref($meas) eq 'ARRAY' or $meas = [$meas];

                my $count = 0;
                for (@$meas) {
                  printf PUSCH_FILE ",meas[$count]";
                  printf PUSCH_FILE ",$_->{sectorCarrierFroId},$_->{rxPower}";
                  $count ++;
                }
              }
              printf PUSCH_FILE ",$_->{servCellIndex},$_->{feedbackRef}";
              printf PUSCH_FILE ",ulcaSchedInfo";
              my $ulcaSchedInfo = $_->{ulCaSchedInfo};
              my $carrierSchedInfo = 
                defined($ulcaSchedInfo->{carrierSchedInfo}) && ref($ulcaSchedInfo->{carrierSchedInfo}) eq 'HASH' ? $ulcaSchedInfo->{carrierSchedInfo}->{carrierSchedInfo} : undef;
              if(defined($carrierSchedInfo)) {
                ref($carrierSchedInfo) eq 'ARRAY' or $carrierSchedInfo = [$carrierSchedInfo];
                my $count = 0;
                for (@$carrierSchedInfo) {
                  printf PUSCH_FILE ",carrierSchedInfo[$count]";
                  printf PUSCH_FILE ",$_->{isScheduled},$_->{duId},$_->{cellId}";
                  $count ++;
                }
              }

              printf PUSCH_FILE "\n";
            } # print the message fields
          }
        }# nrOfPuschReports > 0

      } #if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_UL_IND')


      # LPP_UP_ULMACPE_CI_UL_MAC_CTRL_INFO_IND
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_MAC_CTRL_INFO_IND') 
      {
        my $o = $sig->{data};
        # print the header as the top line for excel file only when the first
        # signal appears.
        if ($outputSignalTable{$SIGNAME} eq "$TRUE")
        {
          open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
          $OUTPUT_FLAG = $TRUE;
          printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subFrameNo";
          printf OUTPUT_FILE ",payloadSize,nrOfUeUlMacCtrlInfo";

          printf OUTPUT_FILE ",crnti,sessionRef,sessionRefInHex,harqInfo,isDtx";
          printf OUTPUT_FILE ",prbListStart,prbListEnd,prbListStart2,prbListEnd2";
          printf OUTPUT_FILE ",ulHarqProcessId,servCellIndex,nrOfSduInfos,nrOfMacCtrlElements,size"; 

          printf OUTPUT_FILE ",macCtrlElement,type,value,value";#print the first macCtrlElement
          printf OUTPUT_FILE ",value,value,value,value"; 
          printf OUTPUT_FILE ",value,value,value,value";
          #printf OUTPUT_FILE ",macCtrlElement2,type,value,value";#print the second macCtrlElement
          #printf OUTPUT_FILE ",value,value,value,value";
          #printf OUTPUT_FILE ",value,value,value,value";
          #printf OUTPUT_FILE ",macCtrlElement3,type,value,value";#print the third macCtrlElement
          #printf OUTPUT_FILE ",value,value,value,value";
          #printf OUTPUT_FILE ",value,value,value,value";
          #printf OUTPUT_FILE ",ePHR,type,scellIndexBitMap,nrOfReports";  #print the ePHR if any
          #printf OUTPUT_FILE ",p,v,powerHeadroom,pcmaxc";
          #printf OUTPUT_FILE ",p,v,powerHeadroom,pcmaxc";
          #deep array again.
          printf OUTPUT_FILE "\n";

          $outputSignalTable{$SIGNAME} = "$FALSE";
        }

        if ($o->{nrOfUeUlMacCtrlInfo} == 0) #todo: to move this condition check to above code block
        {
          next;
        }

        my $ueUlMacCtrlInfo = 
          defined($o->{ueUlMacCtrlInfo}) && ref($o->{ueUlMacCtrlInfo}) eq 'HASH' ? $o->{ueUlMacCtrlInfo}->{ueUlMacCtrlInfo} : undef;
        if(defined($ueUlMacCtrlInfo)) {
          ref($ueUlMacCtrlInfo) eq 'ARRAY' or $ueUlMacCtrlInfo = [$ueUlMacCtrlInfo];

          # print the message fields
          for (@$ueUlMacCtrlInfo) {
            #printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";
            my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
            my $headline = "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";

            #printf OUTPUT_FILE ",$o->{payloadSize},$o->{nrOfUeUlMacCtrlInfo}";
            $headline = "$headline".",$o->{payloadSize},$o->{nrOfUeUlMacCtrlInfo}";

            #printf OUTPUT_FILE ",$_->{header}->{crnti},$_->{header}->{sessionRef},$_->{header}->{harqInfo},$_->{header}->{isDtx}";
            $headline = "$headline".",$_->{header}->{crnti},$_->{header}->{sessionRef},${\convertToHex($_->{header}->{sessionRef})},$_->{header}->{harqInfo},$_->{header}->{isDtx}";

            #printf OUTPUT_FILE ",$_->{header}->{prbListStart},$_->{header}->{prbListEnd},$_->{header}->{prbListStart2},$_->{header}->{prbListEnd2}";
            $headline = "$headline".",$_->{header}->{prbListStart},$_->{header}->{prbListEnd},$_->{header}->{prbListStart2},$_->{header}->{prbListEnd2}",

            #printf OUTPUT_FILE ",$_->{header}->{ulHarqProcessId},$_->{header}->{servCellIndex},$_->{header}->{nrOfSduInfos},$_->{header}->{nrOfMacCtrlElements},$_->{header}->{size}"; 
            $headline = "$headline".",$_->{header}->{ulHarqProcessId},$_->{header}->{servCellIndex},$_->{header}->{nrOfSduInfos},$_->{header}->{nrOfMacCtrlElements},$_->{header}->{size}";

            #check the mactrl element part, which is not that easy.
            if ($_->{header}->{nrOfMacCtrlElements} > 0)
            {
              my $macCtrlElementList = $_->{macCtrlElementList};
              if (defined($macCtrlElementList) && (ref($macCtrlElementList) eq 'HASH'))
              {

                while (my($key, $value) = each %$macCtrlElementList){
                  printf OUTPUT_FILE "$headline";
                  if ($key eq "powerHeadroomReport")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{powerHeadroom}";
                  }
                  elsif ($key eq "cRnti")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{crnti}";
                  }
                  elsif ($key eq "truncatedBSR")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{bufferSize}";
                  }
                  elsif ($key eq "shortBSR")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{bufferSize}";
                  }
                  elsif ($key eq "longBSR")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{bufferSizeNr1Nr2},$value->{bufferSizeNr3Nr4}";
                  }
                  elsif ($key eq "tuneOut")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},FNplus:,$value->{FNplus},SFN:,$value->{SFN},SF:,$value->{SF},tuneOutType:,$value->{tuneOutType},SCI:,$value->{SCI}";
                  }
                  elsif ($key eq "ueCollaboration")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},notParse,notParse,notParse,$value->{length},$value->{ueUlDataInd}";
                  }
                  elsif ($key eq "extendedPowerHeadroomReport")
                  {
                    printf OUTPUT_FILE ",$key,$value->{type},$value->{scellIndexBitMap},$value->{nrOfReports}";
                    my $extendedPowerHrReport = 
                      defined($value->{extendedPowerHrReport}) && ref($value->{extendedPowerHrReport}) eq 'HASH' ? $value->{extendedPowerHrReport}->{extendedPowerHrReport} : undef;
                    if(defined($extendedPowerHrReport)) {
                      ref($extendedPowerHrReport) eq 'ARRAY' or $extendedPowerHrReport = [$extendedPowerHrReport];

                    #=====================================
                      # print the message fields
                      for (@$extendedPowerHrReport) 
                      {
                        printf OUTPUT_FILE ",p:$_->{p},v:$_->{v},powerHeadroom:$_->{powerHeadroom},pcmaxc:$_->{pcmaxc}";
                      }
                    #===========================================

                    }
                  }
                  printf OUTPUT_FILE "\n";
                }
              }
              else
              {
                print "one error happened when parse mac ctrl element\n";
                exit 1;
              }
            } #if ($_->{header}->{nrOfMacCtrlElements} > 0)
            else
            {
               #nrOfMaccTrlElements is zero, still print out it because it might
               #contain DTX or NACK.
               printf OUTPUT_FILE "$headline\n";

            }





            #printf OUTPUT_FILE ",$_->{bbUeRef},$_->{isDtx}->{isDtx},$_->{muIndex}";
            #printf OUTPUT_FILE ",rxPower,$_->{rxPower}->{prbListStart},$_->{rxPower}->{prbListEnd},$_->{rxPower}->{prbListStart2},$_->{rxPower}->{prbListEnd2},$_->{rxPower}->{rxPowerReport},$_->{rxPower}->{sinr}";
            #printf OUTPUT_FILE ",$_->{sectorMeas}->{sinrOfPrimarySector},$_->{servCellIndex}";
            #printf OUTPUT_FILE "\n";
          }

          #Try to implement another way to go through all the key->value pair.
          #Because only the last value is a number, only the last key is
          #printed. Use non-DiGui method, it is very hard to print it, because I
          #don't know the exact deepth of this structure.
        }

      } #if ($SIGNAME eq 'LPP_UP_ULL1PE_EI_ALLOCATION_IND')


      #===================================================
      # LPP_UP_ULCELLPE_CI_CELL_STATUS_REPORT_IND
      if ($SIGNAME eq 'LPP_UP_ULCELLPE_CI_CELL_STATUS_REPORT_IND') 
      {
        my $o = $sig->{data};
        # print the header as the top line for excel file only when the first
        # signal appears.
        if ($outputSignalTable{$SIGNAME} eq "$TRUE")
        {
          open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
          $OUTPUT_FLAG = $TRUE;
          printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNo";
          printf OUTPUT_FILE ",ulPrbBandwidth";
          printf OUTPUT_FILE ",puschIntNoisePwr,pucchIntNoisePwr";

          #deep array again.
          for(my $i =1; $i <=100; $i++){
            printf OUTPUT_FILE ",PRB $i";
          }

          printf OUTPUT_FILE "\n";

          $outputSignalTable{$SIGNAME} = "$FALSE";
        }

        if ($o->{ulPrbBandwidth} == 0)
        {
          next;
        }

        my $tti = calculateTti($o->{sfn},$o->{subFrameNo});
        printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{cellId},$o->{sfn},$o->{subFrameNo}";
        printf OUTPUT_FILE ",$o->{ulPrbBandwidth}";
        printf OUTPUT_FILE ",$o->{puschIntNoisePwr},$o->{pucchIntNoisePwr}";

        #my $intNoisePwrPerPrb = 
          #defined($o->{intNoisePwrPerPrb}) && ref($o->{intNoisePwrPerPrb}) eq 'HASH' ? $o->{intNoisePwrPerPrb}->{intNoisePwrPerPrb} : undef;
        my $intNoisePwrPerPrb = 
          defined($o->{intNoisePwrPerPrb}) && ref($o->{intNoisePwrPerPrb}) eq 'HASH' ? $o->{intNoisePwrPerPrb}->{intNoisePwrPerPrb} : undef;
        if(defined($intNoisePwrPerPrb)) {
          ref($intNoisePwrPerPrb) eq 'ARRAY' or $intNoisePwrPerPrb = [$intNoisePwrPerPrb];

        # print the message fields
        for (@$intNoisePwrPerPrb) {
          #my $cfrInfo = 
            #defined($o->{intNoisePwrPerPrb}->{intNoisePwrPerPrb}->{l1}->{cfrInfo}) && ref($o->{intNoisePwrPerPrb}->{intNoisePwrPerPrb}->{l1}->{cfrInfo}) eq 'HASH' ? $o->{intNoisePwrPerPrb}->{intNoisePwrPerPrb}->{l1}->{cfrInfo}->{cfrInfo} : undef;
          #printf OUTPUT_FILE ",$_->{intNoisePwrPerPrb}";
          printf OUTPUT_FILE ",$_";
        }
        printf OUTPUT_FILE "\n";

          #Try to implement another way to go through all the key->value pair.
          #Because only the last value is a number, only the last key is
          #printed. Use non-DiGui method, it is very hard to print it, because I
          #don't know the exact deepth of this structure.
        }

      } #if ($SIGNAME eq 'LPP_UP_ULL1PE_EI_ALLOCATION_IND') 


      #===================================================
      # LPP_UP_DLMACPE_CI_DL_UE_ALLOC_IND
      if ($SIGNAME eq 'LPP_UP_DLMACPE_CI_DL_UE_ALLOC_IND') 
      {
        my $o = $sig->{data};
        # print the header as the top line for excel file only when the first
        # signal appears.
        if ($outputSignalTable{$SIGNAME} eq "$TRUE")
        {
          open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
          $OUTPUT_FLAG = $TRUE;
          printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subframeNr";
          printf OUTPUT_FILE ",nrOfUe";

          printf OUTPUT_FILE ",bbUeRef,bbUeRefInHex,decisionIndex,priorOutOfSync";
          printf OUTPUT_FILE ",rnti,txScheme,txMode,prbResourceIndicatorType";
          printf OUTPUT_FILE ",prbList,prbList,prbList,prbList";
          printf OUTPUT_FILE ",swapFlag,nrOfLayers,nrOfTb";

          printf OUTPUT_FILE ",tbIndex,newDataFlag,tbSizeInBytes,dlHarqProcessId,nrOfMacCtrlElem";
          printf OUTPUT_FILE ",lcid,type,data,data,data";
          printf OUTPUT_FILE "\n";

          $outputSignalTable{$SIGNAME} = "$FALSE";
        }

        if ($o->{nrOfUe} == 0)
        {
          next;
        }
        my $ueAlloc = 
          defined($o->{ueAlloc}) && ref($o->{ueAlloc}) eq 'HASH' ? $o->{ueAlloc}->{ueAlloc} : undef;
        if(defined($ueAlloc)) {
          ref($ueAlloc) eq 'ARRAY' or $ueAlloc = [$ueAlloc];

          # print the message fields
          for (@$ueAlloc) {
            my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subframeNr});
            my $headline = "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subframeNr}";
            $headline = "$headline".",$o->{nrOfUe}";

            $headline = "$headline".",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{decisionIndex},$_->{priorOutOfSync}";
            $headline = "$headline".",$_->{l1Control}->{rnti},$_->{l1Control}->{txScheme},$_->{l1Control}->{txMode},$_->{l1Control}->{prbResourceIndicatorType}";

            # "to print one array: 4 prblist
            my $prbList = 
              defined($_->{l1Control}->{prbList}) && ref($_->{l1Control}->{prbList}) eq 'HASH' ? $_->{l1Control}->{prbList}->{prbList} : undef;
            if (defined($prbList))
            {
              ref($prbList) eq 'ARRAY' or $prbList = [$prbList];
              for (@$prbList) {
                $headline = "$headline".",$_";
              }
            }
            
            $headline = "$headline".",$_->{l1Control}->{swapFlag},$_->{l1Control}->{nrOfLayers},$_->{nrOfTb}";
            my $tbCount = $_->{nrOfTb};

            my $tbAlloc = 
              defined($_->{tbAlloc}) && ref($_->{tbAlloc}) eq 'HASH' ? $_->{tbAlloc}->{tbAlloc} : undef;
            if (defined($tbAlloc))
            {
              ref($tbAlloc) eq 'ARRAY' or $tbAlloc = [$tbAlloc];
              
              for (@$tbAlloc) {
                $tbCount--;
                if ($tbCount >= 0)
                {
                  my $tbHeadline = "$headline".",$_->{tbIndex},$_->{commonTb}->{newDataFlag},$_->{commonTb}->{tbSizeInBytes},$_->{macTb}->{dlHarqProcessId},$_->{macTb}->{nrOfMacCtrlElem}";

                  if ($_->{macTb}->{nrOfMacCtrlElem} == 0)
                  {
                    printf OUTPUT_FILE "$tbHeadline";
                    printf OUTPUT_FILE "\n";
                  }
                  else
                  {
                    my $printCount = $_->{macTb}->{nrOfMacCtrlElem};
                    my $macCeAlloc = 
                      defined($_->{macTb}->{macCeAlloc}) && ref($_->{macTb}->{macCeAlloc}) eq 'HASH' ? $_->{macTb}->{macCeAlloc}->{macCeAlloc} : undef;
                    if (defined($macCeAlloc))
                    {
                      ref($macCeAlloc) eq 'ARRAY' or $macCeAlloc = [$macCeAlloc];
                      for (@$macCeAlloc) {
                        
                        $printCount--;
                        if ($printCount >= 0)
                        {
                          printf OUTPUT_FILE "$tbHeadline";
                          printf OUTPUT_FILE ",$_->{lcid}";

                          my $type = "unknown";
                          if ($_->{lcid} == 26)
                          {
                            $type = "LongDrxCommand";
                          }
                          elsif ($_->{lcid} == 27)
                          {
                            $type = "Activation/Deactivation";
                          }
                          elsif ($_->{lcid} == 28)
                          {
                            $type = "UeContentionResolutionIdentity ";
                          }
                          elsif ($_->{lcid} == 29)
                          {
                            $type = "TimingAdvanceCommand";
                          }
                          elsif ($_->{lcid} == 30)
                          {
                            $type = "DrxCommand";
                          }
                          printf OUTPUT_FILE ",$type";

                          my $data = 
                            defined($_->{data}) && ref($_->{data}) eq 'HASH' ? $_->{data}->{data} : undef;
                          if (defined($data))
                          {
                            ref($data) eq 'ARRAY' or $data = [$data];
                            for (@$data) {
                              printf OUTPUT_FILE ",$_";
                            }
                          }

                          printf OUTPUT_FILE "\n";
                        } #if ($printCount >= 0)
                      } #for (@$macCeAloc)
                    }#if (defined($macCeAlloc))
                    # to do by begood, here the rlcTb isn't be printed out. Probalby later we need it also.
                    
                  }#if ($_->{macTb}->{nrOfMacCtrlElem} == 0)
                }#if ($tbCount >= 0)
              }#for (@$tbAlloc) 
            }
          }

          #Try to implement another way to go through all the key->value pair.
          #Because only the last value is a number, only the last key is
          #printed. Use non-DiGui method, it is very hard to print it, because I
          #don't know the exact deepth of this structure.
        }

      } #if ($SIGNAME eq 'LPP_UP_DLMACPE_CI_DL_UE_ALLOC_IND')


      #====================================================
      if ($SIGNAME eq 'UPC_DLMACCE_FI_UL_PDCCH_REQ') 
      {
        my $o = $sig->{data};
        my $sePdcchReqList = defined($o->{sePdcchReqList}) && ref($o->{sePdcchReqList}) eq 'HASH' ? $o->{sePdcchReqList}->{sePdcchReqList} : undef;
        if(defined($sePdcchReqList)) {
          ref($sePdcchReqList) eq 'ARRAY' or $sePdcchReqList = [$sePdcchReqList];

          # print the header as the top line for excel file.
          if ($outputSignalTable{$SIGNAME} eq "$TRUE")
          {
            open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
            $OUTPUT_FLAG = $TRUE;
            printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,signal";
            printf OUTPUT_FILE ",cellId,bbCellIdx,subFrameNr,nrOfSesInSePdcchReqList";
            printf OUTPUT_FILE ",rnti,bbUeRef,bbUeRefInHex,requiredTbs,seWeight,cceCost,mapDci0ToCommonSearchSpace,estimatedNrOfSbs,requestedDciFormat";
            printf OUTPUT_FILE ",servCellIndex,isLowCoverageUe";
            printf OUTPUT_FILE "\n";

            $outputSignalTable{$SIGNAME} = "$FALSE";
          }
          # print the message fields
          for (@$sePdcchReqList) {
            printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$m->{signame}";
            printf OUTPUT_FILE ",$o->{cellId},$o->{bbCellIdx},$o->{subFrameNr},$o->{nrOfSesInSePdcchReqList}";
            printf OUTPUT_FILE ",$_->{rnti},$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{requiredTbs},$_->{seWeight},$_->{cceCost},$_->{mapDci0ToCommonSearchSpace},$_->{estimatedNrOfSbs},$_->{requestedDciFormat}";
            printf OUTPUT_FILE ",$_->{servCellIndex},$_->{isLowCoverageUe}";
            printf OUTPUT_FILE "\n";
          }
        }
      } #if ($SIGNAME eq 'UPC_DLMACCE_FI_UL_PDCCH_REQ')


      # LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_DL_IND
      #====================================================
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_L1_MEASRPRT2_DL_IND') 
      {
        my $o = $sig->{data};

        if ($o->{nrOfPuschReports} > 0)
        {
          my $puschReportList = defined($o->{puschReportList}) && ref($o->{puschReportList}) eq 'HASH' ? $o->{puschReportList}->{puschReportList} : undef;
          if(defined($puschReportList)) {
            ref($puschReportList) eq 'ARRAY' or $puschReportList = [$puschReportList];

            # print the header as the top line for excel file.
            if ($outputSignalTable{$SIGNAME}->{Pusch} eq "$TRUE")
            {
              open (PUSCH_FILE, ">$outputFile.$outputSigName.PUSCH.csv") || die "Sorry, create $outputSigName  output file failed!\n";
              $PUSCH_FLAG = $TRUE;

              my $printTopLine = $TRUE;
              for (@$puschReportList)
              {
                if ($printTopLine != $TRUE )
                {
                  next;
                }
                printf PUSCH_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
                printf PUSCH_FILE ",cellId,sfn,subFrameNo,nrOfPuschReports";
                printf PUSCH_FILE ",bbUeRef,bbUeRefInHex,isDtx";

                #my $cfrPusch = 
                  #defined($o->{puschReportList}->{puschReportList}->{cfrPusch}) && ref($o->{puschReportList}->{puschReportList}->{cfrPusch}) eq 'HASH' ? $o->{puschReportList}->{puschReportList}->{cfrPusch}->{cfrPusch} : undef;
                #my $cfrPusch = $_->{cfrPusch};
                my $cfrPusch = 
                  defined($_->{cfrPusch}) && ref($_->{cfrPusch}) eq 'HASH' ? $_->{cfrPusch}->{cfrPusch} : undef;
                if(defined($cfrPusch)) {
                  ref($cfrPusch) eq 'ARRAY' or $cfrPusch = [$cfrPusch];

                  my $count = 0;
                  for (@$cfrPusch) {
                    printf PUSCH_FILE ",cfrPusch[$count]";
                    printf PUSCH_FILE ",ri,riBitWidth,cfrLength,cfrFormat,cfrValid,cfrExpected,cfrCrcFlag,dlBandwidth";

                    my $cfr = 
                      defined($_->{cfr}) && ref($_->{cfr}) eq 'HASH' ? $_->{cfr}->{cfr} : undef;
                    if (defined($cfr))
                    {
                      ref($cfr) eq 'ARRAY' or $cfr = [$cfr];
                      my $internalCount = 0;
                      for (@$cfr) {
                        if ($internalCount == 0)
                        {
                          printf PUSCH_FILE ",cqiWideBand";
                        }
                        printf PUSCH_FILE ",cfr[$internalCount]";
                        $internalCount ++;
                      }
                    }
                    $count ++;
                  }
                }

                printf PUSCH_FILE ",beamformingIndex,beam0Index,beam1Index,polarizationIndex,valid";
                printf PUSCH_FILE ",servCellIndex";
                my $ulcaSchedInfo = $_->{ulCaSchedInfo};
                my $carrierSchedInfo = 
                  defined($ulcaSchedInfo->{carrierSchedInfo}) && ref($ulcaSchedInfo->{carrierSchedInfo}) eq 'HASH' ? $ulcaSchedInfo->{carrierSchedInfo}->{carrierSchedInfo} : undef;
                if(defined($carrierSchedInfo)) {
                  ref($carrierSchedInfo) eq 'ARRAY' or $carrierSchedInfo = [$carrierSchedInfo];
                  my $count = 0;
                  for (@$carrierSchedInfo) {
                    printf PUSCH_FILE ",carrierSchedInfo[$count]";
                    printf PUSCH_FILE ",isScheduled,duId,cellId";
                    $count ++;
                  }
                }


                printf PUSCH_FILE "\n";
                $outputSignalTable{$SIGNAME}->{Pusch} = "$FALSE";

                $printTopLine = $FALSE;
              }
            } # print the header as the top line for excel file.

            # print the message fields
            for (@$puschReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf PUSCH_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf PUSCH_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfPuschReports}";
              printf PUSCH_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{isDtx}->{isDtx}";

              my $cfrPusch = 
                defined($_->{cfrPusch}) && ref($_->{cfrPusch}) eq 'HASH' ? $_->{cfrPusch}->{cfrPusch} : undef;
              if(defined($cfrPusch)) {
                ref($cfrPusch) eq 'ARRAY' or $cfrPusch = [$cfrPusch];

                my $count = 0;
                for (@$cfrPusch) {
                  printf PUSCH_FILE ",cfrPusch[$count]";
                  printf PUSCH_FILE ",$_->{cfrInfo}->{ri},$_->{cfrInfo}->{riBitWidth},$_->{cfrInfo}->{cfrLength},$_->{cfrInfo}->{cfrFormat},$_->{cfrInfo}->{cfrValid},$_->{cfrInfo}->{cfrExpected},$_->{cfrInfo}->{cfrCrcFlag},$_->{cfrInfo}->{dlBandwidth}";

                  my $cfrFormat = $_->{cfrInfo}->{cfrFormat};
                  my $cfrValid = $_->{cfrInfo}->{cfrValid};
                  my $cfr = 
                    defined($_->{cfr}) && ref($_->{cfr}) eq 'HASH' ? $_->{cfr}->{cfr} : undef;
                  if (defined($cfr))
                  {
                    ref($cfr) eq 'ARRAY' or $cfr = [$cfr];
                    my $internalCount = 0;
                    for (@$cfr) {
                      if ($internalCount == 0)
                      {
                        #one hacking way to decode wideband cqi
                        if (($cfrFormat == 4) && ($cfrValid == 1))
                        {
                          #ELIB_BBBASE_COMMON_CFR_FORMAT_SCQI_RI 4
                          my $WB_SIZE = 4;
                          my $cqiWideBand = $_ >> (16 - $WB_SIZE);
                          printf PUSCH_FILE ",$cqiWideBand";
                        }
                        else
                        {
                          #Not supported by this scripte yet.
                          printf PUSCH_FILE ",notCalculate";
                        }
                      }
                      printf PUSCH_FILE ",$_";
                      $internalCount ++;
                    }
                  }
                  $count ++;
                }
              }

              printf PUSCH_FILE ",beamformingIndex,$_->{beamformingIndex}->{beam0Index},$_->{beamformingIndex}->{beam1Index},$_->{beamformingIndex}->{polarizationIndex},$_->{beamformingIndex}->{valid}";
              printf PUSCH_FILE ",$_->{servCellIndex}";
              my $ulcaSchedInfo = $_->{ulCaSchedInfo};
              my $carrierSchedInfo = 
                defined($ulcaSchedInfo->{carrierSchedInfo}) && ref($ulcaSchedInfo->{carrierSchedInfo}) eq 'HASH' ? $ulcaSchedInfo->{carrierSchedInfo}->{carrierSchedInfo} : undef;
              if(defined($carrierSchedInfo)) {
                ref($carrierSchedInfo) eq 'ARRAY' or $carrierSchedInfo = [$carrierSchedInfo];
                my $count = 0;
                for (@$carrierSchedInfo) {
                  printf PUSCH_FILE ",carrierSchedInfo[$count]";
                  printf PUSCH_FILE ",$_->{isScheduled},$_->{duId},$_->{cellId}";
                  $count ++;
                }
              }

              printf PUSCH_FILE "\n";
            } # print the message fields
          }
        }# nrOfPuschReports > 0


        if ($o->{nrOfPucchReports} > 0)
        {
          my $pucchReportList = defined($o->{pucchReportList}) && ref($o->{pucchReportList}) eq 'HASH' ? $o->{pucchReportList}->{pucchReportList} : undef;
          if(defined($pucchReportList)) {
            ref($pucchReportList) eq 'ARRAY' or $pucchReportList = [$pucchReportList];

            # print the header as the top line for excel file.
            if ($outputSignalTable{$SIGNAME}->{Pucch} eq "$TRUE")
            {
              open (PUCCH_FILE, ">$outputFile.$outputSigName.PUCCH.csv") || die "Sorry, create $outputSigName  output file failed!\n";
              $PUCCH_FLAG = $TRUE;

              my $printTopLine = $TRUE;
              for (@$pucchReportList)
              {

                if ($printTopLine != $TRUE)
                {
                  next;
                }
                printf PUCCH_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
                printf PUCCH_FILE ",cellId,sfn,subFrameNo,nrOfPucchReports";
                printf PUCCH_FILE ",bbUeRef,bbUeRefInHex,isDtx";
                printf PUCCH_FILE ",rxPower,prbListStart,prbListEnd,prbListStart2,prbListEnd2,rxPowerReport,sinr";

                printf PUCCH_FILE ",cfrInfo,ri,riBitWidth,cfrLength,cfrFormat,cfrValid,cfrExpected,cfrCrcFlag,dlBandwidth";

                my $cfr = $_->{cfrPucch}->{cfr}->{cfr};
                my $cfrFormat = $_->{cfrPucch}->{cfrInfo}->{cfrFormat};
                if (defined($cfr))
                {
                  ref($cfr) eq 'ARRAY' or $cfr = [$cfr];
                  my $internalCount = 0;
                  for (@$cfr) {
                    if ($internalCount == 0)
                    {
                      printf PUCCH_FILE ",reportType,value";
                    }
                    printf PUCCH_FILE ",cfr[$internalCount]";
                    $internalCount ++;
                  }
                }
                  print PUCCH_FILE ",cfrCarrierNo";

                printf PUCCH_FILE "\n";
                $outputSignalTable{$SIGNAME}->{Pucch} = "$FALSE";

                $printTopLine = $FALSE;
              }
            }
            # print the message fields
            for (@$pucchReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf PUCCH_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf PUCCH_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfPucchReports}";
              printf PUCCH_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})},$_->{isDtx}->{isDtx}";
              printf PUCCH_FILE ",rxPower,$_->{rxPower}->{prbListStart},$_->{rxPower}->{prbListEnd},$_->{rxPower}->{prbListStart2},$_->{rxPower}->{prbListEnd2},$_->{rxPower}->{rxPowerReport},$_->{rxPower}->{sinr}";

              my $cfrPucch = $_->{cfrPucch};
              printf PUCCH_FILE ",cfrInfo,$cfrPucch->{cfrInfo}->{ri},$cfrPucch->{cfrInfo}->{riBitWidth},$cfrPucch->{cfrInfo}->{cfrLength},$cfrPucch->{cfrInfo}->{cfrFormat},$cfrPucch->{cfrInfo}->{cfrValid},$cfrPucch->{cfrInfo}->{cfrExpected},$cfrPucch->{cfrInfo}->{cfrCrcFlag},$cfrPucch->{cfrInfo}->{dlBandwidth}";

              my $cfrFormat = $cfrPucch->{cfrInfo}->{cfrFormat};
              my $cfrValid = $cfrPucch->{cfrInfo}->{cfrValid};
              my $cfr = 
                defined($cfrPucch->{cfr}) && ref($cfrPucch->{cfr}) eq 'HASH' ? $cfrPucch->{cfr}->{cfr} : undef;
              if (defined($cfr))
              {
                ref($cfr) eq 'ARRAY' or $cfr = [$cfr];
                my $internalCount = 0;
                for (@$cfr) {
                  if ($internalCount == 0)
                  {
                    #one hacking way to decode wideband cqi
                    if (($cfrFormat == 0) && ($cfrValid == 1))
                    {
                      printf PUCCH_FILE ",cqiWideBand"; # here reportType is wcqi
                      # define ELIB_BBBASE_COMMON_CFR_FORMAT_WCQI 0
                      my $WB_SIZE = 4;
                      my $cqiWideBand = $_ >> (16 - $WB_SIZE);
                      printf PUCCH_FILE ",$cqiWideBand";
                    }
                    elsif (($cfrFormat == 1) && ($cfrValid == 1))
                    {
                      #define ELIB_BBBASE_COMMON_CFR_FORMAT_RI 1
                      printf PUCCH_FILE ",ri";
                      printf PUCCH_FILE ",$_";

                    }
                    else
                    {
                      #Not supported by this scripte yet.
                      printf PUCCH_FILE ",unknown";
                      printf PUCCH_FILE ",$_";
                    }
                  }
                  printf PUCCH_FILE ",$_";
                  $internalCount ++;
                }
              }
              print PUCCH_FILE ",$_->{cfrCarrierNo}";

              printf PUCCH_FILE "\n";
            }
          }

        }# nrOfPucchReports > 0

      } #if ($SIGNAME eq 'UPC_DLMACCE_FI_UL_PDCCH_REQ')


      #todo: LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND
      #====================================================
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND') 
      {
        my $o = $sig->{data};

        if (($o->{nrOfPuschReports} > 0) || ($o->{nrOfPucchReports} > 0))
        {
          if ($outputSignalTable{$SIGNAME} eq "$TRUE")
          {
            #open OUTPUT_FILE
            open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
            $OUTPUT_FLAG = $TRUE;
            printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal";
            printf OUTPUT_FILE ",cellId,sfn, subFrameNo,nrOfPuschReports,nrOfPucchReports";
            printf OUTPUT_FILE ",bbUeRef,bbUeRefInHex";
            printf OUTPUT_FILE ",fromChannel";

            #print common header, it will be used by dlHarq from pucch and dlHarq from pusch.
            if ($o->{nrOfPuschReports} > 0)
            {

              
              my $puschHarqReportList = defined($o->{puschHarqReportList}) && ref($o->{puschHarqReportList}) eq 'HASH' ? $o->{puschHarqReportList}->{puschHarqReportList} : undef;
              if(defined($puschHarqReportList)) {
                ref($puschHarqReportList) eq 'ARRAY' or $puschHarqReportList = [$puschHarqReportList];

                  my $printTopLine = $TRUE;
                  # print the message fields
                  for (@$puschHarqReportList) {

                    if ($printTopLine != $TRUE)
                    {
                      next;
                    }

                    my $dlHarqInfo = 
                      defined($_->{dlHarqInfo}) && ref($_->{dlHarqInfo}) eq 'HASH' ? $_->{dlHarqInfo}->{dlHarqInfo} : undef;
                    if(defined($dlHarqInfo)) {
                      ref($dlHarqInfo) eq 'ARRAY' or $dlHarqInfo = [$dlHarqInfo];

                      my $count = 0;
                      for (@$dlHarqInfo) {
                        printf OUTPUT_FILE ",dlHarqInfo[$count]";
                        printf OUTPUT_FILE ",dlHarqValid,dlHarqProcessId,nrOfTb,srPresent,anMode,detectedHarqIndication";
                        $count ++;
                      }
                    }

                    printf OUTPUT_FILE ",servCellIndex,puschPucchHarqAmbiguity";
                    printf OUTPUT_FILE "\n";
                    $outputSignalTable{$SIGNAME} = "$FALSE";

                    $printTopLine = $FALSE;
                  } # print the message fields
                } #if(defined($puschHarqReportList)) 

            }
            elsif ($o->{nrOfPucchReports} > 0)
            {

              my $pucchHarqReportList = defined($o->{pucchHarqReportList}) && ref($o->{pucchHarqReportList}) eq 'HASH' ? $o->{pucchHarqReportList}->{pucchHarqReportList} : undef;
              if(defined($pucchHarqReportList)) {
                ref($pucchHarqReportList) eq 'ARRAY' or $pucchHarqReportList = [$pucchHarqReportList];

                  my $printTopLine = $TRUE;
                  # print the message fields
                  for (@$pucchHarqReportList) {

                    if ($printTopLine != $TRUE)
                    {
                      next;
                    }

                    my $dlHarqInfo = 
                      defined($_->{dlHarqInfo}) && ref($_->{dlHarqInfo}) eq 'HASH' ? $_->{dlHarqInfo}->{dlHarqInfo} : undef;
                    if(defined($dlHarqInfo)) {
                      ref($dlHarqInfo) eq 'ARRAY' or $dlHarqInfo = [$dlHarqInfo];

                      my $count = 0;
                      for (@$dlHarqInfo) {
                        printf OUTPUT_FILE ",dlHarqInfo[$count]";
                        printf OUTPUT_FILE ",dlHarqValid,dlHarqProcessId,nrOfTb,srPresent,anMode,detectedHarqIndication";
                        $count ++;
                      }
                    }

                    printf OUTPUT_FILE ",servCellIndex,puschPucchHarqAmbiguity";
                    printf OUTPUT_FILE "\n";
                    $outputSignalTable{$SIGNAME} = "$FALSE";

                    $printTopLine = $FALSE;
                  } # print the message fields
                } #if(defined($pucchHarqReportList)) 


              }


          }
        }
        
        # handle dlHarq from pusch
        if ($o->{nrOfPuschReports} > 0)
        {
          my $puschHarqReportList = defined($o->{puschHarqReportList}) && ref($o->{puschHarqReportList}) eq 'HASH' ? $o->{puschHarqReportList}->{puschHarqReportList} : undef;
          if(defined($puschHarqReportList)) {
            ref($puschHarqReportList) eq 'ARRAY' or $puschHarqReportList = [$puschHarqReportList];

            # print the message fields
            for (@$puschHarqReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf OUTPUT_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfPuschReports},$o->{nrOfPucchReports}";

              printf OUTPUT_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})}";
              printf OUTPUT_FILE ",PUSCH";

              my $dlHarqInfo = 
                defined($_->{dlHarqInfo}) && ref($_->{dlHarqInfo}) eq 'HASH' ? $_->{dlHarqInfo}->{dlHarqInfo} : undef;
              if(defined($dlHarqInfo)) {
                ref($dlHarqInfo) eq 'ARRAY' or $dlHarqInfo = [$dlHarqInfo];

                my $count = 0;
                for (@$dlHarqInfo) {
                  printf OUTPUT_FILE ",dlHarqInfo[$count]";
                  printf OUTPUT_FILE ",$_->{dlHarqValid},$_->{dlHarqProcessId},$_->{nrOfTb},$_->{srPresent},$_->{anMode},$_->{detectedHarqIndication}";
                  $count ++;
                }
              }
              printf OUTPUT_FILE ",$_->{servCellIndex},$_->{puschPucchHarqAmbiguity}";
              printf OUTPUT_FILE "\n";
            } # print the message fields
          }
        }# nrOfPuschReports > 0

        # handle dlHarq from pucch
        if ($o->{nrOfPucchReports} > 0)
        {
          my $pucchHarqReportList = defined($o->{pucchHarqReportList}) && ref($o->{pucchHarqReportList}) eq 'HASH' ? $o->{pucchHarqReportList}->{pucchHarqReportList} : undef;
          if(defined($pucchHarqReportList)) {
            ref($pucchHarqReportList) eq 'ARRAY' or $pucchHarqReportList = [$pucchHarqReportList];

            # print the message fields
            for (@$pucchHarqReportList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame}";
              printf OUTPUT_FILE ",$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo},$o->{nrOfPuschReports},$o->{nrOfPucchReports}";

              printf OUTPUT_FILE ",$_->{bbUeRef},${\convertToHex($_->{bbUeRef})}";
              printf OUTPUT_FILE ",PUCCH";

              my $dlHarqInfo = 
                defined($_->{dlHarqInfo}) && ref($_->{dlHarqInfo}) eq 'HASH' ? $_->{dlHarqInfo}->{dlHarqInfo} : undef;
              if(defined($dlHarqInfo)) {
                ref($dlHarqInfo) eq 'ARRAY' or $dlHarqInfo = [$dlHarqInfo];

                my $count = 0;
                for (@$dlHarqInfo) {
                  printf OUTPUT_FILE ",dlHarqInfo[$count]";
                  printf OUTPUT_FILE ",$_->{dlHarqValid},$_->{dlHarqProcessId},$_->{nrOfTb},$_->{srPresent},$_->{anMode},$_->{detectedHarqIndication}";
                  $count ++;
                }
              }
              printf OUTPUT_FILE ",n/a,$_->{puschPucchHarqAmbiguity}";
              printf OUTPUT_FILE "\n";
            } # print the message fields
          }

        }# nrOfPucchReports > 0

      } #if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_UL_L1_HARQFDBK2_DL_IND')

      #===================================================
      # LPP_UP_ULMACPE_CI_DL_HARQ_ALLOC_IND
      if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_DL_HARQ_ALLOC_IND') 
      {
        my $o = $sig->{data};
        if ($o->{noOfHarqAllocations} > 0)
        {

          my $harqAllocList = 
            defined($o->{harqAllocList}) && ref($o->{harqAllocList}) eq 'HASH' ? $o->{harqAllocList}->{harqAllocList} : undef;
          if(defined($harqAllocList)) {
            ref($harqAllocList) eq 'ARRAY' or $harqAllocList = [$harqAllocList];

          # print the header as the top line for excel file only when the first
          # signal appears.
          if ($outputSignalTable{$SIGNAME} eq "$TRUE")
          {
            open (OUTPUT_FILE, ">$outputFile.$outputSigName.csv") || die "Sorry, create $outputSigName  output file failed!\n";
            $OUTPUT_FLAG = $TRUE;


            my $printTopLine = $TRUE;
            for (@$harqAllocList) 
            {
              if ($printTopLine != $TRUE )
              {
                next;
              }
              printf OUTPUT_FILE "line,date,time,sigSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,tti,signal,cellId,sfn,subFrameNo";
              printf OUTPUT_FILE ",dlSubframeNr,noOfHarqAllocations";

              printf OUTPUT_FILE ",bbUeRef,crnti,rxPucchSector,caHarqFeedbackMode,sCellsConfigured,freqOffEstPusch";

              printf OUTPUT_FILE ",tddDlHarqBundlingInfo";
              printf OUTPUT_FILE ",nBundled,dlMaxNrOfBundledSubframes,bundlingSubframeIndex,anMode,multiplexingAmbiguityMode";


              #deep array again.
              #printf OUTPUT_FILE ",cfrExpected,cfrExpected,cfrExpected";
              my $carrierHarqInfo = 
              defined($_->{carrierHarqInfo}) && ref($_->{carrierHarqInfo}) eq 'HASH' ? $_->{carrierHarqInfo}->{carrierHarqInfo} : undef;
              if (defined($carrierHarqInfo))
              {
                ref($carrierHarqInfo) eq 'ARRAY' or $carrierHarqInfo = [$carrierHarqInfo];

                my $count = 0;
                for (@$carrierHarqInfo) {
                  printf OUTPUT_FILE ",carrierHarqInfo[$count]";
                  printf OUTPUT_FILE ",ElibBbBaseCommonPucchResource,valid,dlHarqProcessId,nrOfTb,maxNrOfTbs,isPCell,isCceIndex";
                  $count++;
                }
              }
             
              printf OUTPUT_FILE "\n";
              $outputSignalTable{$SIGNAME} = "$FALSE";

              $printTopLine = $FALSE;
            
                #Try to implement another way to go through all the key->value pair.
                #Because only the last value is a number, only the last key is
                #printed. Use non-DiGui method, it is very hard to print it, because I
                #don't know the exact deepth of this structure.
              }


            } # for (@$harqAllocList) 

          }


            # print the message fields
            for (@$harqAllocList) {
              my $tti = calculateTti($o->{header}->{sfn},$o->{header}->{subFrameNo});
              printf OUTPUT_FILE "$m->{line},$m->{date},$m->{time},$m->{sigSeqNo},$m->{originalBfnSfBf},$m->{bfn},$m->{sfn},$m->{sf},$m->{bf},$tti,$m->{signame},$o->{header}->{cellId},$o->{header}->{sfn},$o->{header}->{subFrameNo}";
              printf OUTPUT_FILE ",$o->{dlSubframeNr},$o->{noOfHarqAllocations}";

              printf OUTPUT_FILE ",$_->{bbUeRef},$_->{crnti},$_->{rxPucchSector},$_->{caHarqFeedbackMode},$_->{sCellsConfigured},$_->{freqOffEstPusch}";

              printf OUTPUT_FILE ",tddDlHarqBundlingInfo";
              printf OUTPUT_FILE ",$_->{tddDlHarqBundlingInfo}->{nBundled},$_->{tddDlHarqBundlingInfo}->{dlMaxNrOfBundledSubframes},$_->{tddDlHarqBundlingInfo}->{bundlingSubframeIndex},$_->{tddDlHarqBundlingInfo}->{anMode},$_->{tddDlHarqBundlingInfo}->{multiplexingAmbiguityMode}";

              my $carrierHarqInfo = 
                defined($_->{carrierHarqInfo}) && ref($_->{carrierHarqInfo}) eq 'HASH' ? $_->{carrierHarqInfo}->{carrierHarqInfo} : undef;
              if (defined($carrierHarqInfo))
              {
                ref($carrierHarqInfo) eq 'ARRAY' or $carrierHarqInfo = [$carrierHarqInfo];
                my $count = 0;
                for (@$carrierHarqInfo) {
                  printf OUTPUT_FILE ",carrierHarqInfo[$count]";
                  printf OUTPUT_FILE ",$_->{ElibBbBaseCommonPucchResource},$_->{valid},$_->{dlHarqProcessId},$_->{nrOfTb},$_->{maxNrOfTbs},$_->{isPCell},$_->{isCceIndex}";
                  $count++;
                }
              }

              printf OUTPUT_FILE "\n";
            }


            #Try to implement another way to go through all the key->value pair.
            #Because only the last value is a number, only the last key is
            #printed. Use non-DiGui method, it is very hard to print it, because I
            #don't know the exact deepth of this structure.
          
        } #if ($o->{noOfHarqAllocations} > 0)

      } #if ($SIGNAME eq 'LPP_UP_ULMACPE_CI_DL_HARQ_ALLOC_IND')

    } #if ($SIGNAME eq $outputSigName)

  } #for my $sig (@signals)

  if ($OUTPUT_FLAG eq "$TRUE") { close (OUTPUT_FILE); $OUTPUT_FLAG = $FALSE; }
  if ($PUCCH_FLAG eq "$TRUE") {close (PUCCH_FILE); $PUCCH_FLAG=$FALSE;}
  if ($PUSCH_FLAG eq "$TRUE") {close (PUSCH_FILE); $PUSCH_FLAG=$FALSE;}
  if ($SRS_FLAG   eq "$TRUE") {close (SRS_FILE);   $SRS_FLAG  =$FALSE;}
  if ($POWER_FLAG   eq "$TRUE") {close (POWER_FILE);   $POWER_FLAG  =$FALSE;}
  #if ($PDCCH_FLAG eq "$TRUE") {close (PDCCH_FILE); $PDCCH_FLAG=$FALSE;}
  #if ($PDSCH_FLAG eq "$TRUE") {close (PDSCH_FILE); $PDSCH_FLAG=$FALSE;}

  my @fds = glob "$outputFile.$outputSigName*.csv";
  foreach my $fd (@fds)
  { 
    $_ = $fd;
    s/^.+[\/]//g;
    print "$_ generated.\n";
  }

}

#empty the baseband signal array.
@signals = ();

#=======================================filter baseband trace secondly======
seek INPUT_FILE, 0, 0 or confess "Seek to file head failed:$!";
print "\nFind below baseband traces:\n";
while (<INPUT_FILE>) {
  chomp;

  if (/^\s*\[(?<date>[^\s]+)\s+(?<time>[^\s]+)\]\s+(?<originalBfnSfBf>\w+).*
         bfn:(?<bfn>\d+),\s+
         sfn:(?<sfn>\d+),\s+
         sf:(?<sf>[^,]+),\s+
         bf:(?<bf>\d+).*
         duId:(?<duId>\d+).*
         <!(?<traceId>[a-zA-Z]+\.\d+)!>\s+
         (?<traceContent>.+)$/x
       )
         #[2016-09-22 11:50:40.671843] 0x32a7ccbb=(bfn:810, sfn:810, sf:8.27, bf:203) duId:1 EMCA4/UpcUlMacCeFt_UL_VALIDATION TIMER ulmacce_postvalidfo.c:1766: <!UPCUL.1493!> cellId=72
  {
    # in below if condition, also trace one unique trace: 0x4dc343c4.
     # the corresponding signal counter++. 
     if (exists($traceTable{$+{traceId}}))
     {
        $traceTable{$+{traceId}}++;
     }
     else
     {
       $traceTable{$+{traceId}} = 1;
       print "$+{traceId}\n";
     }

     # put the sigSeqNo/Counter and originalBfnSfBf into the meta data.
     $ctx->{meta} = {
       line => $.,
       traceSeqNo => $traceTable{$+{traceId}},
       date => "["."$+{date}"."]",
       time => "["."$+{time}"."]",
       originalBfnSfBf => $+{originalBfnSfBf},
       bfn => $+{bfn},
       sfn => $+{sfn},
       sf => $+{sf},
       bf => $+{bf},
       traceId => $+{traceId},
     };

     #print Dumper(\$ctx->{meta});

     ## make date and timee also be included.
     #my $date = $+{date};
     #my $time = $+{time};
     ##operate date
     #$_ = $date;
     #s/^\[//;
     #$ctx->{meta}->{date} = $_;
     ##operate time
     #$_ = $time;
     #s/]$//;
     #$ctx->{meta}->{time} = $_;

     #my ($name, $o) = parseStruct;
     #$ctx->{state} = 0;
     #$ctx->{meta}->{traceId} = $name;
     
     my $trace = {
       meta => $ctx->{meta},
       data => $+{traceContent},
     };
     push @traces, $trace;
     #print "push $ctx->{meta}->{traceSeqNo} $ctx->{meta}->{date} $ctx->{meta}->{time} $ctx->{meta}->{traceId} into array.\n";
  }
}

print "\nTotal baseband traces:\n";
while (my ($key, $value) = each %traceTable) {
    print "$key => $value times\n";
  }

print "\n\n";

# output baseband trace object
while (my ($traceId, $traceCount) = each %traceTable) 
{
  # Example
  my $index = 0;
  for my $trace (@traces) 
  {
     ## put the sigSeqNo/Counter and originalBfnSfBf into the meta data.
     #$ctx->{meta} = {
     #  line => $.,
     #  traceSeqNo => $traceTable{$+{traceId}},
     #  date => $+{date},
     #  time => $+{time},
     #  originalBfnSfBf => $+{originalBfnSfBf},
     #  bfn => $+{bfn},
     #  sfn => $+{sfn},
     #  sf => $+{sf},
     #  bf => $+{bf},
     #  traceId => $+{traceId},
     #};
     #
     #my $trace = 
     #  meta => $ctx->{meta},
     #  data => $+{traceContent},
    my $meta = $trace->{meta};         # $meta is a hash table.
    if ($meta->{traceId} ne $traceId)
    {
      next;
    }

    my $traceContent = $trace->{data}; 
    
    #print $content information
    #traceContent should be divided into several levels:
    #1) split according to " " space.
    $_ = $traceContent;
    #s/(\{.+)\s+(.+\})/$1$2/g; #to improve by begod. Currently, it is not good enough to decode UPCUL.173
    #s/(\[.+)\s+(.+\])/$1$2/g;
    #
    #[2016-11-02 19:21:04.170071] 0xf3522bfb=(bfn:3893, sfn:821, sf:2.27, bf:191) duId:1 EMCA4/UpcUlMacCeFt_UL_VALIDATION TIMER ulmacce_postvalidfo.c:1523: <!UPCUL.170!> cellId=4,                bbUeRef=0x04017da0 ulSfn=821 ulSubframe=8 : Valid SE. rnti=29991 nrOfUlCarriers=1 servCellIndex=[0,0] timeWhenLastScheduledPerQ={1994,0,6352,0} timeWhenLastAverageRateUpdate={0,0,8211,0}    timeSinceLastValidation=1 timeSinceFirstSr=65535 validationType=[5,0] harqState=[2,0] harqStateBitMap=0x0005 firstUlCarrierWithHarqProc=0 averageRate={0,0,13977,0} type={{4,2,0}, {4,2,0},   {0,1,2}, {4,2,0}} weight={{{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}}, {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}}} pqWeight={{0,0,0,0,0}, {0,0,0,0,0}} isCqiReporting=[0,0]  
    s/\},\s+\{/\},\{/g; #to improve by begod. Currently, it is not good enough to decode UPCUL.173
    s/\],\s+\[/\],\[/g;
    my @fields = split /\s+/, $_;
    #2) split according to "=".

    if ($index == 0)
    {
      open (OUTPUT_FILE, ">$outputFile.$traceId.csv") || die "Sorry, create $traceId output file failed!\n";
      printf OUTPUT_FILE "line,date,time,traceSeqNo,originalBfnSfBf,bfn,sfn,sf,bf,traceId";
      foreach my $field (@fields)
      {
        $_ = $field;
        s/,$//g;
        if ($_ =~ m/(?<var>.+)=(?<value>.+)/)
        {
          #Need to remove , within the value field
          $_ = $+{var};
          s/,/|/g;
          #printf OUTPUT_FILE ",$+{var}";
          printf OUTPUT_FILE ",$_";
        }
        else
        {
          printf OUTPUT_FILE ",$_";
        }
      }
      printf OUTPUT_FILE "\n";

    }

    printf OUTPUT_FILE "$meta->{line},$meta->{date},$meta->{time},$meta->{traceSeqNo},$meta->{originalBfnSfBf},$meta->{bfn},$meta->{sfn},$meta->{sf},$meta->{bf},$meta->{traceId}";
    foreach my $field (@fields)
    {
      $_ = $field;
      s/,$//g;
      if ($_ =~ m/(?<var>.+)=(?<value>.+)/)
      {
        #Need to remove , within the value field
        $_ = $+{value};
        s/,/|/g;
        printf OUTPUT_FILE ",$_";
        #printf OUTPUT_FILE ",$+{value}";
        #if (defined($_))
        #{
          #printf OUTPUT_FILE ",$_";
        #}
        #else
        #{
          #print "attentation $meta->{line},$meta->{date},$meta->{time},$meta->{traceSeqNo},$meta->{originalBfnSfBf},$meta->{bfn},$meta->{sfn},$meta->{sf},$meta->{bf},$meta->{traceId}";
          #print "originalBfnSfBf=$meta->{originalBfnSfBf}";
          #print "\n";
          ##  exit 0;
        #}
      
      }
      else
      {
        printf OUTPUT_FILE ",$_";
      }
    }
    printf OUTPUT_FILE "\n";


    $index++;
  } #for my $sig (@signals)

  close (OUTPUT_FILE);

  my @fds = glob "$outputFile.$traceId.csv";
  foreach my $fd (@fds)
  { 
    $_ = $fd;
    s/^.+[\/]//g;
    print "$_ generated.\n";
  }

  #if (-e "$outputFile.$traceId.csv")
  #{
    #print "$outputFile.$traceId.csv generated.\n";
  #}
}

#empty trace array
@traces = ();

#sub displayHash{
  #my $hashInput = shift;
  #my $firstPrintFlag = shift;


  #if (ref($hashInput) eq 'HASH')
  #{
    #while (($key, $value) = each %$hashInput){
      #print “$key => $value\n”;
    #}

  #}
        #my $ulL1PuschAllocationStructList = 
          #defined($o->{ulL1PuschAllocationStructList}) && ref($o->{ulL1PuschAllocationStructList}) eq 'HASH' ? $o->{ulL1PuschAllocationStructList}->{ulL1PuschAllocationStructList} : undef;

  ##if it is an array, print it out.

  ##if it is a 

#}

sub addMember {
  my $o = shift;
  my $name = shift;
  my $value = shift;

  if (exists($o->{$name})) {
    if (ref($o->{$name}) eq 'ARRAY') {
      push @{$o->{$name}}, $value;
    } else {
      $o->{$name} = [
        $o->{$name},
        $value
      ];
    }
  } else {
    $o->{$name} = $value;
  }
}

sub parseStruct {
  my $o = {};
  my $name = "";

  # Parse struct name
  while (<INPUT_FILE>) {
    chomp;
    if (/^\s*(?<name>[^\s]+)\s+{\s*$/x) {
      $name = $+{name};
      last;
    }
  }

  # Parse members
  my $pos = tell INPUT_FILE;
  while (<INPUT_FILE>) {
    chomp;
    /^\s*},?\s*$/ and last; # Close structure
    /^\s*$/ and next; # Ignore blank lines
    if (/^\s*(?<name>[^\s]+)\s+(?<value>[^{,]+),?\s*$/) {
      addMember $o, $+{name}, $+{value};
    } elsif (/^\s*(?<name>[^\s]+)\s+{\s*$/) {
      seek INPUT_FILE, $pos, 0 or confess "Seek failed:$!";
      my ($name, $v) = parseStruct();
      addMember $o, $name, $v;
    } else {
      confess "Don't know how to parse '$_'";
    }
    $pos = tell INPUT_FILE;
  }

  return ($name, $o);
}

sub convertToHex{
  my $decValue = shift;

  my $hexValue = sprintf("%x", $decValue);
  $hexValue ="0x"."$hexValue";
  return ($hexValue);
}

sub mapCceAllocType{
  my $cceAllocType = shift;
  my $mapedCceAllocType;

  my $CCE_ALLOC_NORMAL = 0;
  my $CCE_ALLOC_PM_CONSERVATIVE = 1;
  my $CCE_ALLOC_CONSERVATIVE = 2;
  my $CCE_ALLOC_AGGRESSIVE = 3;

  if ($cceAllocType == $CCE_ALLOC_NORMAL)
  {
    $mapedCceAllocType = "CCE_ALLOC_NORMAL";
  }
  elsif ($cceAllocType == $CCE_ALLOC_PM_CONSERVATIVE)
  {
    $mapedCceAllocType =  "CCE_ALLOC_PM_CONSERVATIVE";
  }
  elsif ($cceAllocType == $CCE_ALLOC_CONSERVATIVE)
  {
    $mapedCceAllocType =  "CCE_ALLOC_CONSERVATIVE";
  }
  elsif ($cceAllocType == $CCE_ALLOC_AGGRESSIVE)
  {
    $mapedCceAllocType =  "CCE_ALLOC_AGGRESSIVE";
  }
  else
  {
    $mapedCceAllocType =  "Unknown";
  }
  
  return $mapedCceAllocType;
}

sub calculateTti{
  my $sfn = shift;
  my $subframeNo = shift;

  my $deltaSfn = 0;

  # No go back from 1023 to 0
  if ($sfn >= $previousSfn)
  {
    # get deltaSfn
    $deltaSfn = $sfn - $previousSfn;
  }
  else 
  {
    # get deltaSfn, go back from 1023 to 0. So need to add 1024 on current $accuSfn
    $deltaSfn = 1024 + $sfn - $previousSfn;
  }

  # increase $accuSfn
  $accuSfn = $accuSfn + $deltaSfn;
 
  #update $previousSfn
  $previousSfn = $sfn;

  #calcute accumulate tti
  my $tti = $accuSfn * 10 + $subframeNo;

  return $tti;
}
