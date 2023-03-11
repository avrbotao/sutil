
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

##  __________________________________________________________________________
## |                                                                          |
## |  The source code in this file is part of the "sutil" software project    |
## |  as developed and released by alexandre botao <from botao dot org> ,     |
## |  available for download from the following public repositories:          |
## |                                                                          |
## |  https://sourceforge.net/u/avrbotao/                                     |
## |  https://bitbucket.org/alexandrebotao/                                   |
## |  https://gitlab.com/alexandre.botao/                                     |
## |  https://github.com/avrbotao/                                            |
## |                                                                          |
## |  This software is free and open-source: you can redistribute it and/or   |
## |  modify it under the terms stated on the GNU General Public License      |
## |  as published by the Free Software Foundation, either version 3 of the   |
## |  License, or (at your option) any later version.                         |
## |                                                                          |
## |   This code is distributed in the hope that it will be useful,           |
## |   but WITHOUT ANY WARRANTY; without even the implied warranty of         |
## |   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                   |
## |   See the GNU General Public License for more details.                   |
## |                                                                          |
## |   You should have received a copy of the GNU General Public License      |
## |   along with this code.  If not, see <http://www.gnu.org/licenses/>,     |
## |   or write to the Free Software Foundation, Inc.,                        |
## |   59 Temple Place, Suite 330, Boston, MA  02111-1307  USA.               |
## |__________________________________________________________________________|
##

##  __________________________________________________________________________
## |                                                                          |
## |   mon-fs                                    alert filesystem threshold   |
## |__________________________________________________________________________|
##

nuf () {
        ssh $SSHOPT $h sh <<EOS
uname -a
uptime
free
EOS
}
SSHOPT="-o StrictHostKeyChecking=no -o PreferredAuthentications=publickey -o connecttimeout=3 -o PasswordAuthentication=no"
A=90
B="email@dom.ain"
F="sensor@sen.der"
S="FILESYSTEM %USED ABOVE THRESHOLD"
U=/var/tmp/.iac$$.una
T=/var/tmp/.iac$$.tmp
E=/var/tmp/.iac$$.err
L=/var/tmp/.iac$$.log
M=/var/tmp/.iac$$.eml
X="^hugetlbfs|^mqueue|^none|^proc|^pstore|^securityfs|^tracefs|^debugfs|^devpts|^fusectl|^/dev/loop|^cgroup|^tmpfs|^udev|^shm|^sunrpc|^sysfs|^overlay|^nsfs|^configfs|^binfmt_misc|^Filesystem"
for h in $*
do
        echo;echo "=== ($h) `date`"
        ssh $SSHOPT $h "uname -a" > $U 2>&1 ; R=$?
        if test $R -ne 0
        then
                echo ">>> ($h) unreachable" ; continue
        fi
        ssh $SSHOPT $h "mount|cut -d ' ' -f 3|xargs -l sudo df -h" 2>$E | egrep -v -e "${X}" > $T ; R=$?
        if test -s $T
        then
                >$L;>$M; while read lin
                do
                        echo "${lin}" | awk -v A=$A '{if(int($5)>A)print $0}' >> $L
                done < $T
                test -s $L && cat $L | sed "s/^/>>> `cat $U|cut -d ' ' -f 2` <<< /" > $M
                test -s $M && cat $M | mailx -r $F -s $S `echo $B` ; test -s $M && cat $M
        else
                echo ">>> ($h) unusable" ; continue
        fi
done
rm -f $T $U $E $L $M
# vi:nu
