#!/home/utils/perl-5.10/5.10.1-nothreads-64/bin/perl

use strict;
use warnings FATAL => qw(all);

use Getopt::Long qw(GetOptions);
use Log::Log4perl qw(:easy);
use String::Random;

my $gen_tree;
my $stat_file;

GetOptions('gen_tree=s'  => \$gen_tree,
           'stat_file=s' => \$stat_file,
           ) or die "Wrong arg\n";

sub gen_dirs {
  my ($dir, $filename) = @_;

  my $log = get_logger();

  $log->info("generating tree in '$dir'...\n");

  my $max_dir_name = 64;
  my $max_dirs     = 10000;

  mkdir $dir;
  my $pattern = new String::Random;
  $pattern->{'A'} = [ 'A'..'Z', 'a'..'z' ];


  my %dirh = ();
  for (my $i = 0; $i < $max_dirs; $i++) {
    my $dir_length = 1 + int(rand($max_dir_name));

    my $dir_name = $pattern->randpattern('A' x $dir_length);
    next if $dir_name eq "";

    $dirh{$dir_name} = 1;
  }

  open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
  foreach my $d (keys %dirh) {
    my $full_dir_name = "$dir/$d";

    mkdir $full_dir_name;
    print $fh "$full_dir_name\n";
    #$log->info("generated [$dir_name]...\n");
  }

  $log->info("tree in '$dir' is generated\n");
  close $fh;
}

sub stat_dirs {
  my ($filename) = @_;

  my $log = get_logger();

  $log->info("reading dir list from $filename...\n");

  open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";
  my $cnt = 0;

  while (my $dir = <$fh>) {
    chomp $dir;

    if (lstat $dir) {
      my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)= lstat $dir;
      #$log->info("$dir => $ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks\n");
      $cnt++;
    } else {
      die "Error: stat failed on '$dir'\n";
    }
    #$log->info("$dir\n");
  }

  $log->info("stated $cnt dirs\n");
  close $fh;
}


sub main
{
  Log::Log4perl->easy_init($INFO);

  die "Error: no -stat_file specified\n" if !$stat_file;

  if ($gen_tree) {
    gen_dirs($gen_tree, $stat_file)
  } else {
    stat_dirs($stat_file)
  }

}

main();

