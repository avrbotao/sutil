
### 
###           |          _                   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
###           |\       _/ \_                 |       alexandre  botao       |
###           | \_    /_    \_               |         botao dot org        |
###           \   \__/  \__   \              |       +55-11-98244-UNIX      |
###            \_    \__/  \_  \             |       +55-11-9933-LINUX      |
###              \_   _/     \ |             |  alexandre at botao dot org  |
###                \_/        \|             |      botao at unix  dot net  |
###                            |             |______________________________|
### 


SWNAME="mcs.sh"
SWVERS="1.0.6"
SWDATE="2022-09-01"
SWTIME="00:00:00"
SWDESC="multiple concurrent stuff"
SWTAGS="multiple,concurrent,parallel,exec,stuff,shell,script"
SWCOPY="BSD2Clause"
SWAUTH="alexandre botao"
SWMAIL="alexandre at botao dot org"


##  __________________________________________________________________________
## |                                                                          |
## |  The source code in this file is part of the "sutil" software project    |
## |  as developed and released by alexandre botao <from botao dot org> ,     |
## |  available for download from the following public repositories:          |
## |  https://sourceforge.net/u/avrbotao/                                     |
## |  https://bitbucket.org/alexandrebotao/                                   |
## |  https://gitlab.com/alexandre.botao/                                     |
## |  https://github.com/avrbotao/                                            |
## |__________________________________________________________________________|
## |                                                                          |
## |  This software is free and open-source: you can use it under the terms   |
## |  of the "2-Clause BSD License" or as stated in the file "sutil-LICENSE"  |
## |  provided with this distribution.                                        |
## |  This software is distributed in hopes of being useful, but WITHOUT ANY  |
## |  EXPRESS OR IMPLIED WARRANTIES as detailed in the aforementioned files.  |
## |__________________________________________________________________________|
##


#______________________________________________________________________________
#

fecho () {
	flg=$1
	shift
	$flg && echo $*
}

vecho () {
	fecho $verboseflag $*
}

decho () {
	fecho $debugflag $*
}

techo () {
	fecho $traceflag $*
}

#______________________________________________________________________________
#

SWPATH=$0
SWPROJ="sutil"
SWBASE=`dirname $0`
SWFILE=`basename $0`
SWNICK=`basename $SWFILE .sh`

getflag=false
putflag=false
runflag=false

mockflag=false
debugflag=false
verboseflag=false
traceflag=false

suffixflag=false

#______________________________________________________________________________
#

showhelp () {
			cat <<EOHELP
use: $SWPATH [ [options] {arg [...]} ]
options:
	--get				fetch file
	--put				send file
	--run				execute command
	--cmd="..."			run this
	--dir=path			work dir
	--list=filename		work list
	--help				show this and exit
-L	--license			show [verbose] license and exit
	--suffix=ext		'.extension' for list files
-v	--verbose			verbose output
-V	--version			show version and exit
EOHELP
	exit 1
}

#______________________________________________________________________________
#

showlicense () {
		cat <<EOCOP

Copyright (c) 2022 Alexandre Botao. All rights reserved.

EOCOP
	if $verboseflag
	then
		LICFIL=${SWBASE}/${SWPROJ}-LICENSE
		if test -s $LICFIL
		then
			cat $LICFIL
		else
			echo ">>> license file ($LICFIL) not found."
		fi
	else
		cat <<EOLIC
(Simplified BSD License; see the file ${LICFIL} for details)

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED "AS IS", AND ANY EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIMS OR DAMAGES ARISING FROM, OUT OF OR
IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE OR OTHER DEALINGS IN THIS SOFTWARE.
EOLIC
	fi
	# echo setlicense bsd2clause
	exit 0
}

#______________________________________________________________________________
#

showversion () {
	echo "$SWNAME $SWVERS $SWDATE"
	exit 1
}

#______________________________________________________________________________
#

#CTO=3
#SSHOPT="-o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -o connecttimeout=$CTO -o PasswordAuthentication=no"

### 
### 
###         __/\        _____________________________________________________
###        /   /       |                                                     |
###       / OO \       |   mcs.sh                multiple concurrent stuff   |
###       \ \/ /       |   (c) [????-]2022           alexandre v. r. botao   |
###        \  /        |_____________________________________________________|
###         \/
### 
### 

techo "... SWBASE $SWBASE SWFILE $SWFILE SWNICK $SWNICK"

###    _______________________________________________________________________
###   |                                                                       |
###   |   prologue                                                            |
###   |_______________________________________________________________________|
###

dlm=";"

###    _______________________________________________________________________
###   |                                                                       |
###   |   parsing                                                             |
###   |_______________________________________________________________________|
###

test $# -lt 1 && set -- "--help"

argt=$#
argk=0
argv=" "
args=" "

while test $# -gt 0
do
	i="$1"
	shift
	case "${i}" in
		### --) echo got -- ; break ;;
#______________________________________________________________________________
#
		--get) getflag=true ;;

		--put) putflag=true ;;

		--run) runflag=true ; act=run ; MEXT=m${act} ;;
#______________________________________________________________________________
#
		--help) showhelp ;;

		--license) showlicense ;;

		--mock) mockflag=true ;;

		--debug) debugflag=true ;;

		--trace) traceflag=true ;;

		--verbose) verboseflag=true ;;

		--version) showversion ;;
#______________________________________________________________________________
#
#																custom longopts
		--parm)							### longopt parm model
			parm=$1
			shift
			argv="${argv}parm=${parm} "
		;;

		--suffix=*)						### longopt=value model
			suffixflag=true
			ext="`echo ${i} | cut -d '=' -f 2`"
			argv="${argv}`echo ${i} | tr -d '-'` "
		;;
#______________________________________________________________________________
#
		--cmd=*)
			cmd="`echo ${i} | cut -d '=' -f 2`"
			ACTINF="${cmd}"
			argv="${argv}`echo ${i} | tr -d '-'` "
		;;

		--dir=*)
			dir="`echo ${i} | cut -d '=' -f 2`"
			ACTDIR="${dir}"
			argv="${argv}`echo ${i} | tr -d '-'` "
		;;

		--list=*)
			lst="`echo ${i} | cut -d '=' -f 2`"
			ACTLST="${lst}"
			argv="${argv}`echo ${i} | tr -d '-'` "
		;;
#______________________________________________________________________________
#
		--*=*)
			echo "??? longoption=value ($i)"
			argv="${argv}`echo ${i} | tr -d '-'` "
		;;

		--*)
			echo "??? long option ($i) invalid"
			argv="${argv}${i} "
		;;
#______________________________________________________________________________
#
		#	custom shortopts
		-p)		### shortopt parm model
			parm=$1
			shift
			argv="${argv}parm=${parm} "
		;;
#______________________________________________________________________________
#
		-L) showlicense ;;

		-v) verboseflag=true ;;

		-V) showversion ;;

		-?)
			## showhelp $SWNICK
			echo "??? short option ($i) invalid"
			argv="${argv}${i} "
		;;

		-*)
			### set -- $(echo "${i}" | cut -c 2- | sed 's/./-& /g') "$@"
			set -- `echo "$i" | cut -c 2- | sed 's/./-& /g'` "$@"
			continue
		;;

		*)
			argn=`expr $argt - $#`
			techo "=== argt ($argt) argn ($argn) argc ($#)"
			if $suffixflag
			then
				if [ -f ${i}.${ext} ]
				then
					if [ -s ${i}.${ext} ]
					then
						if echo ${listlist} | grep "|${i}|" >/dev/null 2>&1
						then
							echo ">>> list recursion detected ($i)"
						else
							echo "... list (${i}.${ext})"
							listlist="|${i}|${listlist}|"
							set -- `cat ${i}.${ext}` "$@"
						fi
					else
						echo ">>> empty (${i}.${ext})"
					fi
				fi
			fi
			if [ -f "${i}" ]
			then
				techo "=== fil ($i)"
				argv="${argv}${i} "
				args="$args${i} "
			elif [ -d "${i}" ]
			then
				techo "=== dir ($i)"
				argv="${argv}${i}/ "
				args="$args${i} "
			else
				techo "=== arg ($i)"
				argv="${argv}${i} "
				args="$args${i} "
				argk=`expr $argk + 1`
			fi
		;;
	esac
done

###    _______________________________________________________________________
###   |                                                                       |
###   |   drudgery                                                            |
###   |_______________________________________________________________________|
###

techo "... argc ($#)"
techo "... argt ($argt)"
techo "... argn ($argn)"
techo "... argk ($argk)"
techo "... argv ($argv)"
techo "... args ($args)"
techo "... rest ($@)"

#______________________________________________________________________________
#

test -x /usr/bin/xargs && XA=/usr/bin/xargs
test -x /usr/local/bin/xargs && XA=/usr/local/bin/xargs

PFX=.mcs

## test -z "$ACTDIR" && ACTDIR=/var/tmp/${PFX}.${RANDOM}.$$

ACTSCR=$ACTDIR/${MEXT}.sh

test -z "$act" && echo ">>> action undefined" && exit 1
test -z "$ACTDIR" && echo ">>> dir undefined" && exit 1
test -z "$ACTINF" && echo ">>> info undefined" && exit 1
test -z "$ACTLST" && echo ">>> list undefined" && exit 1

vecho "=== what ($act) info ($ACTINF) dir ($ACTDIR) list ($ACTLST) scr ($ACTSCR)"

test -d $ACTDIR || mkdir -p $ACTDIR
cd $ACTDIR
test $? -ne 0 && echo ">>> dir ($ACTDIR) inaccessible" && exit 1
dd if=/dev/zero of=.z1m. count=1024 >.err. 2>&1
# ls -la ; cat -n .err.
test $? -ne 0 && echo ">>> dir ($ACTDIR) unusable" && exit 1
rm -f .z1m. .err.

MERR=merr
P=10

#______________________________________________________________________________
#

if test $runflag
then
	cat > $ACTSCR <<EOR
H=\$1
if test -z "\$H"
then
	echo "noarg;-1" >> ${MEXT}.log
else
	ULBS=/usr/bin/
	if test -n "\$ULBLIST"
	then
		if grep -i "^\${H}$" \$ULBLIST >/dev/null 2>&1
		then
			ULBS=/usr/local/bin/
		fi
	fi
	\${ULBS}ssh ${SSHOPT} \$H "${ACTINF}" > \${H}.${MEXT} 2> \${H}.${MERR}
	echo "\${H};\$?" >> ${MEXT}.log
fi
EOR
fi

#______________________________________________________________________________
#

#______________________________________________________________________________
#

#______________________________________________________________________________
#

$mockflag && echo mock && exit 0

chmod +x $ACTSCR

MES=$ACTDIR/${MEXT}.start
MEC=$ACTDIR/${MEXT}.close

### TRC=-t

vecho "+++ start (`basename $0`) for (`basename $ACTSCR`) on ($ACTLST/$P) at (`date`)" # > ${MES}
$XA $TRC -l -P $P $ACTSCR < $ACTLST
vecho "+++ close (`basename $0`) for (`basename $ACTSCR`) on ($ACTLST/$P) at (`date`)" # > ${MEC}

###    _______________________________________________________________________
###   |                                                                       |
###   |   epilogue                                                            |
###   |_______________________________________________________________________|
###

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#        1         2         3         4         5         6         7         8

# vi:nu ts=4
