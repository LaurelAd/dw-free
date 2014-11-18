#!/usr/bin/perl
#
# This code was forked from the LiveJournal project owned and operated
# by Live Journal, Inc. The code has been modified and expanded by
# Dreamwidth Studios, LLC. These files were originally licensed under
# the terms of the license supplied by Live Journal, Inc, which can
# currently be found at:
#
# http://code.livejournal.org/trac/livejournal/browser/trunk/LICENSE-LiveJournal.txt
#
# In accordance with the original license, this code and all its
# modifications are provided under the GNU General Public License.
# A copy of that license can be found in the LICENSE file included as
# part of this distribution.

use strict;
BEGIN {
    require "$ENV{'LJHOME'}/cgi-bin/ljlib.pl";
}

my $dbh = LJ::get_db_writer();

sub header_text {
    return <<"HEADER";
# This file is automatically generated from MySQL by \$LJHOME/bin/dumpsql.pl
# Don't submit a diff against a hand-modified file - dump and diff instead.

HEADER
}

# what tables don't we want to export the auto_increment columns from
# because they already have their own unique string, which is what matters
my %skip_auto = (
                 "priv_list" => "privcode",
                 "supportcat" => "catkey",
                 "ratelist" => "name",
                 );

# get tables to export
my %tables = ();
my $sth = $dbh->prepare("SELECT tablename, redist_mode, redist_where ".
                        "FROM schematables WHERE redist_mode NOT IN ('off')");
$sth->execute;
while (my ($table, $mode, $where) = $sth->fetchrow_array) {
    $tables{$table}->{'mode'} = $mode;
    $tables{$table}->{'where'} = $where;
}

my %output;  # {general|local} -> [ [ $alphasortkey, $SQL ]+ ]

# dump each table.
foreach my $table (sort keys %tables)
{
    next if $table =~ /^(user|talk|log)proplist$/;

    my $where;
    if ($tables{$table}->{'where'}) {
        $where = "WHERE $tables{$table}->{'where'}";
    }

    my $sth = $dbh->prepare("DESCRIBE $table");
    $sth->execute;
    my @cols = ();
    my $skip_auto = 0;
    while (my $c = $sth->fetchrow_hashref) {
        if ($c->{'Extra'} =~ /auto_increment/ && $skip_auto{$table}) {
            $skip_auto = 1;
        } else {
            push @cols, $c;
        }
    }

    # DESCRIBE table can be different between developers
    @cols = sort { $a->{'Field'} cmp $b->{'Field'} } @cols;

    my $cols = join(", ", map { $_->{'Field'} } @cols);
    my $sth = $dbh->prepare("SELECT $cols FROM $table $where");
    $sth->execute;
    my $sql;
    while (my @r = $sth->fetchrow_array)
    {
        my %vals;
        my $i = 0;
        foreach (map { $_->{'Field'} } @cols) {
            $vals{$_} = $r[$i++];
        }
        my $scope = "general";
        $scope = "local" if (defined $vals{'scope'} &&
                             $vals{'scope'} eq "local");
        my $verb = "INSERT IGNORE";
        $verb = "REPLACE" if ($tables{$table}->{'mode'} eq "replace" &&
                              ! $skip_auto);
        $sql = "$verb INTO $table ";
        $sql .= "($cols) ";
        $sql .= "VALUES (" . join(", ", map { db_quote($_) } @r) . ");\n";

        my $uniqc = $skip_auto{$table};
        my $skey = $uniqc ? $vals{$uniqc} : $sql;
        push @{$output{$scope}}, [ "$table.$skey.1", $sql ];

        if ($skip_auto) {
            # for all the *proplist tables, there might be new descriptions
            # or columns, but we can't do a REPLACE, because that'd mess
            # with their auto_increment ids, so we do insert ignore + update
            my $where = "$uniqc=" . db_quote($vals{$uniqc});
            delete $vals{$uniqc};
            $sql = "UPDATE $table SET ";
            $sql .= join(",", map { "$_=" . db_quote($vals{$_}) } sort keys %vals);
            $sql .= " WHERE $where;\n";
            push @{$output{$scope}}, [ "$table.$skey.2", $sql ];
        }
    }
}


# don't use $dbh->quote because it's changed between versions
# and developers sending patches can't generate concise patches
# it used to not quote " in a single quoted string, but later it does.
# so we'll implement the new way here.
sub db_quote {
    my $s = shift;
    return "NULL" unless defined $s;
    $s =~ s/\\/\\\\/g;
    $s =~ s/\"/\\\"/g;
    $s =~ s/\'/\\\'/g;
    $s =~ s/\n/\\n/g;
    $s =~ s/\r/\\r/g;
    return "'$s'";
}

foreach my $k (keys %output) {
    my $file = $k eq "general" ? "base-data.sql" : "base-data-local.sql";
    print "Dumping $file\n";
    my $ffile = "$ENV{'LJHOME'}/bin/upgrading/$file";
    open (F, ">$ffile") or die "Can't write to $ffile\n";
    print F header_text();
    foreach (sort { $a->[0] cmp $b->[0] } @{$output{$k}}) {
        print F $_->[1];
    }
    close F;
}

# dump proplists, etc
print "Dumping proplists.dat\n";
open (my $plg, ">$ENV{LJHOME}/bin/upgrading/proplists.dat") or die;
open (my $pll, ">$ENV{LJHOME}/bin/upgrading/proplists-local.dat") or die;
foreach my $table ('userproplist', 'talkproplist', 'logproplist', 'usermsgproplist', 'pollproplist2') {
    my $sth = $dbh->prepare("DESCRIBE $table");
    $sth->execute;
    my @cols = ();
    while (my $c = $sth->fetchrow_hashref) {
        die "Where is the 'Extra' column?" unless exists $c->{'Extra'};  # future-proof
        next if $c->{'Extra'} =~ /auto_increment/;
        push @cols, $c;
    }
    @cols = sort { $a->{'Field'} cmp $b->{'Field'} } @cols;
    my $cols = join(", ", map { $_->{'Field'} } @cols);

    my $pri_key = "name";  # for now they're all 'name'.  might add more tables.
    $sth = $dbh->prepare("SELECT $cols FROM $table ORDER BY $pri_key");
    $sth->execute;
    while (my @r = $sth->fetchrow_array) {
        my %vals;
        my $i = 0;
        foreach (map { $_->{'Field'} } @cols) {
            $vals{$_} = $r[$i++];
        }
        my $scope = $vals{'scope'} && $vals{'scope'} eq "local" ? "local" : "general";
        my $fh = $scope eq "local" ? $pll : $plg;
        print $fh "$table.$vals{$pri_key}:\n";
        foreach my $c (map { $_->{'Field'} } @cols) {
            next if $c eq $pri_key;
            next if $c eq "scope";  # implied by filenamea
            print $fh "  $c: $vals{$c}\n";
        }
        print $fh "\n";
    }

}

# and dump mood info
print "Dumping moods.dat\n";
open (F, ">$ENV{'LJHOME'}/bin/upgrading/moods.dat") or die;
$sth = $dbh->prepare("SELECT moodid, mood, parentmood FROM moods ORDER BY moodid");
$sth->execute;
while (@_ = $sth->fetchrow_array) {
    print F "MOOD @_\n";
}

$sth = $dbh->prepare("SELECT moodthemeid, name, des FROM moodthemes WHERE is_public='Y' ORDER BY name");
$sth->execute;
while (my ($id, $name, $des) = $sth->fetchrow_array) {
    $name =~ s/://;
    print F "MOODTHEME $name : $des\n";
    my $std = $dbh->prepare("SELECT moodid, picurl, width, height FROM moodthemedata ".
                            "WHERE moodthemeid=$id ORDER BY moodid");
    $std->execute;
    while (@_ = $std->fetchrow_array) {
        print F "@_\n";
    }
}
close F;


print "Done.\n";