#!/bin/sh
#
# gen-ver.sh for libquvi-scripts
# Copyright (C) 2011  Toni Gundogdu
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301  USA
#
set -e

from_file()
{
  VN=`cat $1 2>/dev/null`
  if test -n "$VN"; then
    echo $VN
    exit 0
  fi
}

gen_version() # $1=path to top source dir
{
  path=$1 ; [ -z $path ] && path=.

  # First check if the version file exists and use its value
  versionfn="$path/VERSION"
  [ -f "$versionfn" ]  && from_file "$versionfn"

  # If that file is not found, or fails (e.g. empty), parse from m4/version.m4
  m4="$path/m4/version.m4"
  VN=`perl -ne'/(\d+)\.(\d+)\.(\d+)/ && print "$1.$2.$3"' < "$m4"`
  [ -z $VN ] && exit $?

  # Use the "git describe" instead, if .git is present
  if test -d "$path/.git" -o -f "$path/.git" ; then
    _VN=`git describe --match "v[0-9]*" --abbrev=4 HEAD 2>/dev/null`
    [ -n "$_VN" ] && VN=$_VN
  fi

  echo $VN
}

help()
{
  echo "Usage: $0 [-h] [top_srcdir]
-h  Show this help and exit
Run without options to print version. Define top_srcdir if run outside
the top source directory."
  exit 0
}

while [ $# -gt 0 ]
do
  case "$1" in
    -h) help;;
    *) break;;
  esac
  shift
done

gen_version $1
