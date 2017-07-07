#!/usr/bin/perl

use warnings;
use strict;
use FileHandle;

use Getopt::Std;

my @rrc_logger_lines;
my $fh;
my $tmp;
my %opts;
my $check_for_bbueref = 0;
my $check_for_this_bbueref = 0;
my $current_bbueref = 0;

#Checking for bbueref flag (-b)
getopts('b:', \%opts);
if($opts{b})
{
  $check_for_bbueref = 1;
  $check_for_this_bbueref = $opts{b};
  print "-b flag: $opts{b}";
}

# Input filename
if (scalar(@ARGV) > 0)
{
  $fh = new FileHandle;
  if ($fh->open("< $ARGV[0]")) 
  {
    @rrc_logger_lines = <$fh>;
    $fh->close;
  }
  else
  {
    print "ERROR : Can not open $ARGV[0] for reading !\n";
    exit 1;
  }
}
else
{
  print "\nUsage:\nscan_baseband_traces_hs_ue.pl <optional flag> <baseband_trace.log>\n";

  print "\nScript scans content of these traces for FOE:\n".
        "mtd peek -ta UpUlL1PeMasterFt -sig LPP_UP_ULL1PE_EI_DATA_IND\n".
        "lhsh gcpu00512 te e trace5 UpUlL1PeSlaveBl_Spucch\n";

  print "\n -b     bbueref    Search for a specific bbueref";

  print "\n";
  exit 1;
}

my %traceStringHash = (
0  => "<!UPULL1.58!>:             ",
1  => "UP_ULL1PE_EI_DATA_IND:     "
);

my $investigate;


my $pucchFirstTime=1;
my $lastBfnSub=0;
my $currentBfnSub = 0;
my $wrappedBfnSub = 0;
my $printBfnSub = 0;

my $investigate_prach = 0;
my $cellId = 0;
my $nrOfPreambles = 0;
my $investigate_prach_preambles = 0;
my $bbUeRef = 0;
my $preambleId = 0;
my $timingOffset = 0;
my $preamblePower = 0;	
my $freqOffEstPrach = 0;

print "bfn+sf;cellId;nrOfPreambles;bbueref;preambleId;timingOffset;preamblePower;freqOffEstPrach;\n";

foreach (@rrc_logger_lines)
{
  $investigate = $_;

#Missing traces
  if ($investigate =~ m|Non-consecutive trace numbers, up to (\d*) traces may be missing|i)
  {
    chomp($investigate);
    print "Alert: $investigate;;$printBfnSub;;;;$1\n";
  }


#[2017-06-26 16:10:34.767138] 0x6194c0c6=(bfn:1561, sfn:537, sf:5.07, bf:12) duId:1 EMCA4/UpcUlMacCeBl_Imtdi BIN_REC : LPP_UPC_ULCELLCE_EI_SCHEDULE_RA_MSG3_IND (839) <= UNKNOWN (sessionRef=0x696be0)
#UpcUlCellCeEiScheduleRaMsg3Ind {
#  sigNo 106,
#  cellId 211,
#  subframeRach 4,
#  sfnRach 537,
#  nrOfDetectedPreambles 1,
#  nrOfPreambles 1,
#  rachPreambleArray {
#    rachPreambleArray {
#      bbUeRef 3544190272,
#      crnti 11413,
#      preambleId 41,
#      timingOffset 1,
#      taCommand 1,
#      preamblePower 4531,
#      raType 0,
#      raPurpose 0,
#      sectorId 0,
#      freqOffEstPrach 0,
#      prachCeLevel 0,
#      padding0 0
#    }
#  }
#} 



#PRACH

  if ($investigate =~ m|.*bfn:(\d*).*sf:(\d*).*LPP_UPC_ULCELLCE_EI_SCHEDULE_RA_MSG3_IND|i)
  {
    $currentBfnSub = $1*10 + $2;
    #Checking if there is a wrapparound of bfn
    if (($currentBfnSub+20000) < $lastBfnSub)
    {
      $wrappedBfnSub = $wrappedBfnSub +1;
    }
    $lastBfnSub = $currentBfnSub;
    $printBfnSub = $wrappedBfnSub*40960 + $currentBfnSub;

    $investigate_prach=1;
  }

  elsif ($investigate_prach==1 && $investigate =~ m|\.*cellId (\S*),|i )
  {
    $cellId = $1;	
  }
  elsif ($investigate_prach==1 && $investigate =~ m|\.*nrOfPreambles (\S*),|i )
  {
    $nrOfPreambles = $1;
    if ($nrOfPreambles == 1)
    {
      $investigate_prach_preambles = 1;
      
    }
    else
    {
	#print "$printBfnSub;$cellId;$nrOfPreambles;\n";
	$investigate_prach=0;
	$investigate_prach_preambles = 0;
    }
  
  }

	if($investigate_prach_preambles == 1)
	{
	  if ($investigate =~ m|\.*bbUeRef (\S*),|i )
	  {
	    $bbUeRef = $1;	
	  }
	  elsif ($investigate =~ m|\.*preambleId (\S*),|i )
	  {
	    $preambleId = $1;	
	  }
	  elsif ($investigate =~ m|\.*timingOffset (\S*),|i )
	  {
	    $timingOffset = $1;	
	  }
	  elsif ($investigate =~ m|\.*preamblePower (\S*),|i )
	  {
	    $preamblePower = $1;	
	  }
	  elsif ($investigate =~ m|\.*freqOffEstPrach (\S*),|i )
	  {
	    $freqOffEstPrach = $1;
	    $investigate_prach_preambles = 0;
	    $investigate_prach = 0;	
	    print "$printBfnSub;$cellId;$nrOfPreambles;$bbUeRef;$preambleId;$timingOffset;$preamblePower;$freqOffEstPrach;\n";
	  }
	}


} #End for-loop
print "\n";

exit 0;
