
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "a PerlIO layer that adds read & write timeout to a handle",
  "dist_author" => [
    "Damien \"dams\" Krotkine"
  ],
  "dist_name" => "PerlIO-via-Timeout",
  "dist_version" => "0.26",
  "license" => "perl",
  "module_name" => "PerlIO::via::Timeout",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Exporter" => "5.57",
    "PerlIO::via" => 0,
    "Scalar::Util" => 0,
    "Time::Out" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::More" => 0,
    "Test::TCP" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
