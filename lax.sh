
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


SWNAME="lax"
SWVERS="1.3.9"
SWDATE="2023/08/08"
SWTIME="00:00:00"
SWDESC="list active expires"
SWTAGS="list,active,expires"
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


# MESH=`basename $0`
# ME=`basename $MESH .sh`

# tos=`uname`

#_______________________________________________________________________________
#

if test $# -eq 0
then
ost=`uname`
test "`sudo whoami`" != "root" && test "`sudo id | cut -d ' ' -f 1`" != "uid=0(root)" && echo ">>> missing privileges" 1>&2 && exit 1
while read lin
do
	i=`echo \$lin | cut -d ':' -f 1`
	case $ost in
		AIX)
			e=" "
			cmd=`sudo /usr/sbin/lsuser -a account_locked \$i | cut -d '=' -f 2` ; res=true
			rag=nada
		;;
		HP-UX)
			e=" "
			if test -f /etc/shadow	### -a ! -d /tcb
			then
				cmd=`sudo /usr/bin/passwd -s \$i 2>/dev/null | tr -s " " | cut -d ' ' -f 2` ; res=LK
				rag=nada
			else
				if sudo /usr/lbin/getprpw root >/dev/null 2>&1
				then
					cmd=`sudo /usr/lbin/getprpw -rm alock \$i` ; res=YES
				else
					cmd=`sudo /usr/bin/passwd -s \$i 2>/dev/null | tr -s " " | cut -d ' ' -f 2` ; res=LK
				fi
				cag=`sudo /usr/lbin/getprpw -m acctexp,exptm,lftm \$i` ; rag="acctexp=-1, exptm=0, lftm=0"
			fi
		;;
		Linux)
			cmd=`sudo /usr/bin/passwd -S \$i 2>/dev/null | cut -d ' ' -f 2 | sed "s/^L$/LK/" | sed "s/locked./LK/" | sed "s/authentication/LK/"` ; res=LK ; e=-e
			cag=`sudo chage -l \$i | grep -i "^password expires" | awk -F':' '{print $2}' | tr -d " "` ; rag="never"
			### cag=`grep "^\${i}:" /etc/shadow | cut -d ':' -f 4-9` ; rag=":::::"
		;;
		SunOS)
			e=" "
			cmd=`sudo /usr/bin/passwd -s \$i 2>/dev/null | tr -s " " | cut -d ' ' -f 2` ; res=LK
			rag=nada
		;;
	esac
	if [ "${cmd}" = "${res}" ]
	then
		blq=LOCKED
	else
		blq=PASSWD
	fi
	if [ "${cag}" = "${rag}" ]
	then
		sag=NEVER
	else
		sag=AGING
	fi
	echo "${blq}:${sag}:${lin}"
done < /etc/passwd
else
	for H in $*
	do
		cat $0 | ssh $SSHOPT ${H} "ksh 2>&1 || sh 2>&1" | grep -v "ksh:" | sed "s/^/${H}:/"
	done
fi
# vi:nu
