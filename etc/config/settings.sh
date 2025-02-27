#----------------------------------*-sh-*--------------------------------------
# =========                 |
# \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
#  \\    /   O peration     |
#   \\  /    A nd           | Copyright (C) 2011-2015 OpenFOAM Foundation
#    \\/     M anipulation  |
#------------------------------------------------------------------------------
# License
#     This file is part of OpenFOAM.
#
#     OpenFOAM is free software: you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
#     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#     FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#     for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.
#
# File
#     etc/config/settings.sh
#
# Description
#     Startup file for OpenFOAM
#     Sourced from OpenFOAM-<VERSION>/etc/bashrc
#
#------------------------------------------------------------------------------

# prefix to PATH
_foamAddPath()
{
    while [ $# -ge 1 ]
    do
        export PATH=$1:$PATH
        shift
    done
}

# prefix to LD_LIBRARY_PATH
_foamAddLib()
{
    while [ $# -ge 1 ]
    do
        export LD_LIBRARY_PATH=$1:$LD_LIBRARY_PATH
	if [ "$WM_ARCH_BASE" == "darwin" ]
	then
	    # do NOT add the lib of MacPort as this might break programs
	    if [ "$1" != "/opt/local/lib" ]
	    then
		export DYLD_LIBRARY_PATH=$1:$DYLD_LIBRARY_PATH
	    fi
	fi
        shift
    done
}

# prefix to MANPATH
_foamAddMan()
{
    while [ $# -ge 1 ]
    do
        export MANPATH=$1:$MANPATH
        shift
    done
}

#------------------------------------------------------------------------------
# Set environment variables according to system type
export WM_ARCH=`uname -s`

case "$WM_ARCH" in
Linux)
    WM_ARCH=linux

    # compiler specifics
    case `uname -m` in
    i686)
        ;;

    x86_64)
        case "$WM_ARCH_OPTION" in
        32)
            export WM_COMPILER_ARCH=64
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m32 -fPIC'
            export WM_CXXFLAGS='-m32 -fPIC'
            export WM_LDFLAGS='-m32'
            ;;
        64)
            WM_ARCH=linux64
            export WM_COMPILER_LIB_ARCH=64
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m64 -fPIC'
            export WM_CXXFLAGS='-m64 -fPIC'
            export WM_LDFLAGS='-m64'
            ;;
        *)
            echo "Unknown WM_ARCH_OPTION '$WM_ARCH_OPTION', should be 32 or 64"\
                 1>&2
            ;;
        esac
        ;;

    ia64)
        WM_ARCH=linuxIA64
        export WM_COMPILER=I64
        ;;

    mips64)
        WM_ARCH=SiCortex64
        WM_MPLIB=MPI
        export WM_COMPILER_LIB_ARCH=64
        export WM_CC='gcc'
        export WM_CXX='g++'
        export WM_CFLAGS='-mabi=64 -fPIC'
        export WM_CXXFLAGS='-mabi=64 -fPIC'
        export WM_LDFLAGS='-mabi=64 -G0'
        ;;

    armv7l)
        WM_ARCH=linuxARM7
        export WM_COMPILER_LIB_ARCH=32
        export WM_CC='gcc'
        export WM_CXX='g++'
        export WM_CFLAGS='-fPIC'
        export WM_CXXFLAGS='-fPIC'
        export WM_LDFLAGS=
        ;;

    ppc64)
        WM_ARCH=linuxPPC64
        export WM_COMPILER_LIB_ARCH=64
        export WM_CC='gcc'
        export WM_CXX='g++'
        export WM_CFLAGS='-m64 -fPIC'
        export WM_CXXFLAGS='-m64 -fPIC'
        export WM_LDFLAGS='-m64'
        ;;

    *)
        echo Unknown processor type `uname -m` for Linux 1>&2
        ;;
    esac
    ;;

SunOS)
    WM_ARCH=SunOS64
    WM_MPLIB=FJMPI
    export WM_COMPILER_LIB_ARCH=64
    export WM_CC='gcc'
    export WM_CXX='g++'
    export WM_CFLAGS='-mabi=64 -fPIC'
    export WM_CXXFLAGS='-mabi=64 -fPIC'
    export WM_LDFLAGS='-mabi=64 -G0'
    ;;

Darwin)
    export WM_ARCH_BASE=darwin

    case `uname -p` in
    powerpc)
	export WM_ARCH=darwinPpc
	;;
    i386)
	export WM_ARCH=darwinIntel
        case $WM_ARCH_OPTION in
        32)
            export WM_COMPILER_LIB_ARCH=32
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m32 -fPIC'
            export WM_CXXFLAGS='-m32 -fPIC'
            export WM_LDFLAGS='-m32'
            ;;
        64)
            WM_ARCH=darwinIntel64
            export WM_COMPILER_LIB_ARCH=64
            export WM_CC='gcc'
            export WM_CXX='g++'
            export WM_CFLAGS='-m64 -fPIC'
            export WM_CXXFLAGS='-m64 -fPIC'
            export WM_LDFLAGS='-m64'
            ;;
        *)
            echo Unknown WM_ARCH_OPTION $WM_ARCH_OPTION, should be 32 or 64
            ;;
        esac
	;;
    *)
        echo "Unknown architecture "`uname -p` "for Darwin"
    esac

    which -s port >/dev/null
    if [ $? -eq "0" -a -d '/opt/local/etc/macports' ]
    then
	if [ "$FOAM_VERBOSE" -a "$PS1" ]
	then
	    echo "Using Macports binaries"
	fi

	export WM_USE_MACPORT=1
	export WM_BASE_COMPILER=`echo $WM_COMPILER | tr -d "[:digit:]"`
	export WM_MACPORT_MPI_VERSION=`echo $WM_COMPILER | tr "[:upper:]" "[:lower:]"`
	export WM_MACPORT_VERSION=`echo $WM_MACPORT_MPI_VERSION | tr -d "[:alpha:]" | sed -e "s/\(.\)\(.\)/\1\.\2/"`

	if [ -z "$WM_CHOSEN_MAC_MPI" ]
	then
	    if [ -e '/opt/local/bin/mpicc' ]
	    then
		readlink /opt/local/bin/mpicc | grep openmpi >/dev/null
		if [ $? -eq "0" ]
		then
		    export WM_MPLIB=MACPORTOPENMPI
		    if [ "$FOAM_VERBOSE" -a "$PS1" ]
		    then
			echo "Using OpenMPI from MacPorts"
		    fi
		else
		    readlink /opt/local/bin/mpicc | grep mpich >/dev/null
		    if [ $? -eq "0" ]
		    then
			export WM_MPLIB=MACPORTMPICH
			if [ "$FOAM_VERBOSE" -a "$PS1" ]
			then
			    echo "Using MPICH from MacPorts"
			fi
		    else
			echo "/opt/local/bin/mpicc neither OpenMPI nor MPICH. Confused. Defaulting to OPENMPI"
			export WM_MPLIB=OPENMPI
		    fi
		fi
	    fi
	else
	    export WM_MPLIB=$WM_CHOSEN_MAC_MPI
	    if [ "$FOAM_VERBOSE" -a "$PS1" ]
	    then
		echo "User chose WM_CHOSEN_MAC_MPI=$WM_CHOSEN_MAC_MPI"
	    fi
	fi

	if [ "$WM_MPLIB" == "MACPORTOPENMPI" ]
	then
	    if [ ! -e "/opt/local/lib/openmpi-$WM_MACPORT_MPI_VERSION" ]
	    then
		export WM_MACPORT_MPI_VERSION=mp
		if [ ! -e "/opt/local/lib/openmpi-$WM_MACPORT_MPI_VERSION" ]
		then
		    echo "Proper OpenMPI not installed. Either do 'port install openmpi-$WM_MACPORT_MPI_VERSION' or 'port install openmpi-default'"
		fi
	    fi
	else
	    if [ "$WM_MPLIB" == "MACPORTMPICH" ]
	    then
		if [ ! -e "/opt/local/lib/mpich-$WM_MACPORT_MPI_VERSION" ]
		then
		    echo "MPICH wants the same version as the used compiler. Do 'port install mpich-$WM_MACPORT_MPI_VERSION'"
		fi
	    fi
	fi

	if [ "$WM_COMPILER" != "Gcc" ]
	then
	    if [ "$WM_BASE_COMPILER" == "Gcc" ]
	    then
		export WM_CC="gcc-mp-$WM_MACPORT_VERSION"
		export WM_CXX="g++-mp-$WM_MACPORT_VERSION"
	    elif [ "$WM_BASE_COMPILER" == "Clang" ]
	    then
		export WM_CC="clang-mp-$WM_MACPORT_VERSION"
		export WM_CXX="clang++-mp-$WM_MACPORT_VERSION"
	    elif [ "$WM_BASE_COMPILER" == "Dragonegg" ]
	    then
		export WM_CC="dragonegg-$WM_MACPORT_VERSION-gcc"
		export WM_CXX="dragonegg-$WM_MACPORT_VERSION-g++"
	    else
		echo "Unknown base compiler $WM_BASE_COMPILER"
	    fi

	    ruleDirBase=$WM_PROJECT_DIR/wmake/rules/$WM_ARCH
	    ruleDirTarget=$ruleDirBase$WM_BASE_COMPILER
	    ruleDir=$ruleDirBase$WM_COMPILER
	    if [ ! -e $ruleDir ]
	    then
		echo "Rule directory $ruleDir not existing. Linking to $ruleDirTarget"
		ln -s $ruleDirTarget $ruleDir
	    fi
	    unset ruleDir ruleDirBase
	fi
    else
	echo "Seems you're not using MacPorts. This is currently not supported/tested. Find this line in 'etc/config/settings.sh', modify it accordingly and send patches to Bernhard"
        export WM_COMPILER=
        export WM_MPLIB=OPENMPI
    fi

    # Make sure that binaries use the best features of the used OS-Version
    # We need to get rid of the revision number from this string. eg turn "10.7.5" into "10.7"
    #    v=(`sw_vers -productVersion | sed 's/\./ /g'`)
    #    export MACOSX_DEPLOYMENT_TARGET="${v[1]}.${v[2]}"
    export MACOSX_DEPLOYMENT_TARGET=`sw_vers -productVersion | sed -e "s/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.\([0-9][0-9]*\)/\1.\2/g"`
    ;;


*)    # an unsupported operating system
    /bin/cat <<USAGE 1>&2

    Your "$WM_ARCH" operating system is not supported by this release
    of OpenFOAM. For further assistance, please contact www.OpenFOAM.org

USAGE
    ;;
esac


#------------------------------------------------------------------------------

# location of the jobControl directory
export FOAM_JOB_DIR=$WM_PROJECT_INST_DIR/jobControl

# wmake configuration
export WM_DIR=$WM_PROJECT_DIR/wmake
export WM_LINK_LANGUAGE=c++
export WM_OPTIONS=$WM_ARCH$WM_COMPILER$WM_PRECISION_OPTION$WM_COMPILE_OPTION

# base executables/libraries
export FOAM_APPBIN=$WM_PROJECT_DIR/platforms/$WM_OPTIONS/bin
export FOAM_LIBBIN=$WM_PROJECT_DIR/platforms/$WM_OPTIONS/lib

# external (ThirdParty) libraries
export FOAM_EXT_LIBBIN=$WM_THIRD_PARTY_DIR/platforms/$WM_OPTIONS/lib

# site-specific directory
siteDir="${WM_PROJECT_SITE:-$WM_PROJECT_INST_DIR/site}"

# shared site executables/libraries
# similar naming convention as ~OpenFOAM expansion
export FOAM_SITE_APPBIN=$siteDir/$WM_PROJECT_VERSION/platforms/$WM_OPTIONS/bin
export FOAM_SITE_LIBBIN=$siteDir/$WM_PROJECT_VERSION/platforms/$WM_OPTIONS/lib

# user executables/libraries
export FOAM_USER_APPBIN=$WM_PROJECT_USER_DIR/platforms/$WM_OPTIONS/bin
export FOAM_USER_LIBBIN=$WM_PROJECT_USER_DIR/platforms/$WM_OPTIONS/lib

# dynamicCode templates
# - default location is the "~OpenFOAM/codeTemplates/dynamicCode" expansion
# export FOAM_CODE_TEMPLATES=$WM_PROJECT_DIR/etc/codeTemplates/dynamicCode

# convenience
export FOAM_APP=$WM_PROJECT_DIR/applications
export FOAM_SRC=$WM_PROJECT_DIR/src
export FOAM_TUTORIALS=$WM_PROJECT_DIR/tutorials
export FOAM_UTILITIES=$FOAM_APP/utilities
export FOAM_SOLVERS=$FOAM_APP/solvers
export FOAM_RUN=$WM_PROJECT_USER_DIR/run

# add wmake to the path - not required for runtime only environment
[ -d "$WM_DIR" ] && PATH=$WM_DIR:$PATH
# add OpenFOAM scripts to the path
export PATH=$WM_PROJECT_DIR/bin:$PATH

# add site-specific scripts to path - only if they exist
if [ -d "$siteDir/bin" ]                        # generic
then
    _foamAddPath "$siteDir/bin"
fi
if [ -d "$siteDir/$WM_PROJECT_VERSION/bin" ]    # version-specific
then
    _foamAddPath "$siteDir/$WM_PROJECT_VERSION/bin"
fi
unset siteDir

_foamAddPath $FOAM_USER_APPBIN:$FOAM_SITE_APPBIN:$FOAM_APPBIN
# Make sure to pick up dummy versions of external libraries last
_foamAddLib  $FOAM_USER_LIBBIN:$FOAM_SITE_LIBBIN:$FOAM_LIBBIN:$FOAM_EXT_LIBBIN:$FOAM_LIBBIN/dummy

# Compiler settings
# ~~~~~~~~~~~~~~~~~
unset gcc_version gmp_version mpfr_version mpc_version
unset MPFR_ARCH_PATH GMP_ARCH_PATH

# Location of compiler installation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -z "$foamCompiler" ]
then
    foamCompiler=system
    echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
    echo "    foamCompiler not set, using '$foamCompiler'" 1>&2
fi

case "${foamCompiler}" in
OpenFOAM | ThirdParty)
    case "$WM_COMPILER" in
    Gcc | Gcc++0x | Gcc48 | Gcc48++0x)
        gcc_version=gcc-4.8.2
        gmp_version=gmp-5.1.2
        mpfr_version=mpfr-3.1.2
        mpc_version=mpc-1.0.1
        ;;
    Gcc49 | Gcc49++0x)
        gcc_version=gcc-4.9.0
        gmp_version=gmp-5.1.2
        mpfr_version=mpfr-3.1.2
        mpc_version=mpc-1.0.1
        ;;
    Clang)
        # using clang - not gcc
        export WM_CC='clang'
        export WM_CXX='clang++'
        clang_version=llvm-3.4.2
        ;;
    *)
        echo 1>&2
        echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
        echo "    Unknown OpenFOAM compiler type '$WM_COMPILER'" 1>&2
        echo "    Please check your settings" 1>&2
        echo 1>&2
        ;;
    esac

    # optional configuration tweaks:
    _foamSource `$WM_PROJECT_DIR/bin/foamEtcFile config/compiler.sh`

    if [ -n "$gcc_version" ]
    then
        gccDir=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER_ARCH/$gcc_version
        gmpDir=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER_ARCH/$gmp_version
        mpfrDir=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER_ARCH/$mpfr_version
        mpcDir=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER_ARCH/$mpc_version

        # Check that the compiler directory can be found
        [ -d "$gccDir" ] || {
            echo 1>&2
            echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
            echo "    Cannot find $gccDir installation." 1>&2
            echo "    Please install this compiler version or if you wish to use the system compiler," 1>&2
            echo "    change the 'foamCompiler' setting to 'system'" 1>&2
            echo
        }

        _foamAddMan     $gccDir/man
        _foamAddPath    $gccDir/bin

        # add compiler libraries to run-time environment
        _foamAddLib     $gccDir/lib$WM_COMPILER_LIB_ARCH

        # add gmp/mpfr libraries to run-time environment
        _foamAddLib     $gmpDir/lib
        _foamAddLib     $mpfrDir/lib

        # add mpc libraries (not need for older gcc) to run-time environment
        if [ -n "$mpc_version" ]
        then
            _foamAddLib     $mpcDir/lib
        fi

        # used by boost/CGAL:
        export MPFR_ARCH_PATH=$mpfrDir
        export GMP_ARCH_PATH=$gmpDir
    fi
    unset gcc_version gccDir
    unset gmp_version gmpDir  mpfr_version mpfrDir  mpc_version mpcDir

    if [ -n "$clang_version" ]
    then
        clangDir=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER_ARCH/$clang_version

        # Check that the compiler directory can be found
        [ -d "$clangDir" ] || {
            echo 1>&2
            echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
            echo "    Cannot find $clangDir installation." 1>&2
            echo "    Please install this compiler version or if you wish to" \
                 " use the system compiler," 1>&2
            echo "    change the 'foamCompiler' setting to 'system'" 1>&2
            echo 1>&2
        }

        _foamAddMan     $clangDir/share/man
        _foamAddPath    $clangDir/bin
    fi
    unset clang_version clangDir
    ;;
system)
    # okay, use system compiler
    ;;
*)
    echo "Warn: foamCompiler='$foamCompiler' is unsupported" 1>&2
    echo "   treating as 'system' instead" 1>&2
    ;;
esac


#
# Add c++0x flags for external programs
#
if [ -n "$WM_CXXFLAGS" ]
then
    case "$WM_COMPILER" in
    Gcc*++0x)
        WM_CXXFLAGS="$WM_CXXFLAGS -std=c++0x"
        ;;
    esac
fi



# Communications library
# ~~~~~~~~~~~~~~~~~~~~~~

unset MPI_ARCH_PATH MPI_HOME FOAM_MPI_LIBBIN

case "$WM_MPLIB" in
SYSTEMOPENMPI)
    # Use the system installed openmpi, get library directory via mpicc
    export FOAM_MPI=openmpi-system

    libDir=`mpicc --showme:link | sed -e 's/.*-L\([^ ]*\).*/\1/'`

    # Bit of a hack: strip off 'lib' and hope this is the path to openmpi
    # include files and libraries.
    export MPI_ARCH_PATH="${libDir%/*}"

    _foamAddLib     $libDir
    unset libDir
    ;;

MACPORTOPENMPI)
	unset OPAL_PREFIX

	export FOAM_MPI=openmpi-macport-$WM_MACPORT_MPI_VERSION

	# Currently not correctly working on MacPorts
	#	libDir=`mpicc-openmpi-$WM_MACPORT_MPI_VERSION --showme:libdirs`
	libDir=/opt/local/lib/openmpi-$WM_MACPORT_MPI_VERSION

	_foamAddLib     $libDir
	unset libDir
	;;

OPENMPI)
    export FOAM_MPI=openmpi-1.6.5
    # optional configuration tweaks:
    _foamSource `$WM_PROJECT_DIR/bin/foamEtcFile config/openmpi.sh`

    export MPI_ARCH_PATH=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER/$FOAM_MPI

    # Tell OpenMPI where to find its install directory
    export OPAL_PREFIX=$MPI_ARCH_PATH

    _foamAddPath    $MPI_ARCH_PATH/bin

    # 64-bit on OpenSuSE 12.1 uses lib64 others use lib
    _foamAddLib     $MPI_ARCH_PATH/lib$WM_COMPILER_LIB_ARCH
    _foamAddLib     $MPI_ARCH_PATH/lib

    _foamAddMan     $MPI_ARCH_PATH/share/man
    ;;

MPICH)
    export FOAM_MPI=mpich2-1.1.1p1
    export MPI_HOME=$WM_THIRD_PARTY_DIR/$FOAM_MPI
    export MPI_ARCH_PATH=$WM_THIRD_PARTY_DIR/platforms/$WM_ARCH$WM_COMPILER/$FOAM_MPI

    _foamAddPath    $MPI_ARCH_PATH/bin

    # 64-bit on OpenSuSE 12.1 uses lib64 others use lib
    _foamAddLib     $MPI_ARCH_PATH/lib$WM_COMPILER_LIB_ARCH
    _foamAddLib     $MPI_ARCH_PATH/lib

    _foamAddMan     $MPI_ARCH_PATH/share/man
    ;;

MPICH-GM)
    export FOAM_MPI=mpich-gm
    export MPI_ARCH_PATH=/opt/mpi
    export MPICH_PATH=$MPI_ARCH_PATH
    export GM_LIB_PATH=/opt/gm/lib64

    _foamAddPath    $MPI_ARCH_PATH/bin

    # 64-bit on OpenSuSE 12.1 uses lib64 others use lib
    _foamAddLib     $MPI_ARCH_PATH/lib$WM_COMPILER_LIB_ARCH
    _foamAddLib     $MPI_ARCH_PATH/lib

    _foamAddLib     $GM_LIB_PATH
    ;;

MACPORTMPICH)
    export FOAM_MPI=mpich-macports-$WM_MACPORT_MPI_VERSION
    export MPI_HOME=$WM_THIRD_PARTY_DIR/$FOAM_MPI

    libDir=/opt/local/lib/mpich-$WM_MACPORT_MPI_VERSION

    _foamAddLib     $libDir
    unset libDir

    ;;

HPMPI)
    export FOAM_MPI=hpmpi
    export MPI_HOME=/opt/hpmpi
    export MPI_ARCH_PATH=$MPI_HOME

    _foamAddPath $MPI_ARCH_PATH/bin

    case `uname -m` in
    i686)
        _foamAddLib $MPI_ARCH_PATH/lib/linux_ia32
        ;;

    x86_64)
        _foamAddLib $MPI_ARCH_PATH/lib/linux_amd64
        ;;
    ia64)
        _foamAddLib $MPI_ARCH_PATH/lib/linux_ia64
        ;;
    *)
        echo Unknown processor type `uname -m` 1>&2
        ;;
    esac
    ;;

SYSTEMMPI)
    export FOAM_MPI=mpi-system

    if [ -z "$MPI_ROOT" ]
    then
        echo 1>&2
        echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
        echo "    Please set the environment variable MPI_ROOT to point to" \
             " the base folder for the system MPI in use." 1>&2
        echo "    Example:" 1>&2
        echo 1>&2
        echo "        export MPI_ROOT=/opt/mpi" 1>&2
        echo 1>&2
    else
        export MPI_ARCH_PATH=$MPI_ROOT

        if [ -z "$MPI_ARCH_FLAGS" ]
        then
            echo 1>&2
            echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
            echo "    MPI_ARCH_FLAGS is not set. Example:" 1>&2
            echo 1>&2
            echo "        export MPI_ARCH_FLAGS=\"-DOMPI_SKIP_MPICXX\"" 1>&2
            echo 1>&2
        fi

        if [ -z "$MPI_ARCH_INC" ]
        then
            echo 1>&2
            echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
            echo "    MPI_ARCH_INC is not set. Example:" 1>&2
            echo 1>&2
            echo "        export MPI_ARCH_INC=\"-I\$MPI_ROOT/include\"" 1>&2
            echo 1>&2
        fi

        if [ -z "$MPI_ARCH_LIBS" ]
        then
            echo 1>&2
            echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
            echo "    MPI_ARCH_LIBS is not set. Example:" 1>&2
            echo 1>&2
            echo "        export MPI_ARCH_LIBS=\"-L\$MPI_ROOT/lib -lmpi\"" 1>&2
            echo 1>&2
        fi
    fi

    ;;

MPI)
    export FOAM_MPI=mpi
    export MPI_ARCH_PATH=/opt/mpi
    ;;

FJMPI)
    export FOAM_MPI=fjmpi
    export MPI_ARCH_PATH=/opt/FJSVmpi2

    _foamAddPath    $MPI_ARCH_PATH/bin
    _foamAddLib     $MPI_ARCH_PATH/lib/sparcv9
    _foamAddLib     /opt/FSUNf90/lib/sparcv9
    _foamAddLib     /opt/FJSVpnidt/lib
    ;;

QSMPI)
    export FOAM_MPI=qsmpi
    export MPI_ARCH_PATH=/usr/lib/mpi

    _foamAddPath    $MPI_ARCH_PATH/bin
    _foamAddLib     $MPI_ARCH_PATH/lib
    ;;

SGIMPI)
    # no trailing slash
    [ "${MPI_ROOT%/}" = "${MPI_ROOT}" ] || MPI_ROOT="${MPI_ROOT%/}"

    export FOAM_MPI="${MPI_ROOT##*/}"
    export MPI_ARCH_PATH=$MPI_ROOT

    if [ ! -d "$MPI_ROOT" -o -z "$MPI_ARCH_PATH" ]
    then
        echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
        echo "    MPI_ROOT not a valid mpt installation directory or ending" \
             " in a '/'." 1>&2
        echo "    Please set MPI_ROOT to the mpt installation directory." 1>&2
        echo "    MPI_ROOT currently set to '$MPI_ROOT'" 1>&2
    fi

    if [ "$FOAM_VERBOSE" -a "$PS1" ]
    then
        echo "Using SGI MPT:" 1>&2
        echo "    MPI_ROOT : $MPI_ROOT" 1>&2
        echo "    FOAM_MPI : $FOAM_MPI" 1>&2
    fi

    _foamAddPath    $MPI_ARCH_PATH/bin
    _foamAddLib     $MPI_ARCH_PATH/lib
    ;;

INTELMPI)
    # no trailing slash
    [ "${MPI_ROOT%/}" = "${MPI_ROOT}" ] || MPI_ROOT="${MPI_ROOT%/}"

    export FOAM_MPI="${MPI_ROOT##*/}"
    export MPI_ARCH_PATH=$MPI_ROOT

    if [ ! -d "$MPI_ROOT" -o -z "$MPI_ARCH_PATH" ]
    then
        echo "Warning in $WM_PROJECT_DIR/etc/config/settings.sh:" 1>&2
        echo "    MPI_ROOT not a valid mpt installation directory or ending" \
             " in a '/'." 1>&2
        echo "    Please set MPI_ROOT to the mpt installation directory." 1>&2
        echo "    MPI_ROOT currently set to '$MPI_ROOT'" 1>&2
    fi

    if [ "$FOAM_VERBOSE" -a "$PS1" ]
    then
        echo "Using INTEL MPI:" 1>&2
        echo "    MPI_ROOT : $MPI_ROOT" 1>&2
        echo "    FOAM_MPI : $FOAM_MPI" 1>&2
    fi

    _foamAddPath    $MPI_ARCH_PATH/bin64
    _foamAddLib     $MPI_ARCH_PATH/lib64
    ;;
*)
    export FOAM_MPI=dummy
    ;;
esac

# add (non-dummy) MPI implementation
# dummy MPI already added to LD_LIBRARY_PATH and has no external libraries
if [ "$FOAM_MPI" != dummy ]
then
    _foamAddLib $FOAM_LIBBIN/$FOAM_MPI:$FOAM_EXT_LIBBIN/$FOAM_MPI
fi



# Set the minimum MPI buffer size (used by all platforms except SGI MPI)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: ${minBufferSize:=20000000}

if [ "${MPI_BUFFER_SIZE:=$minBufferSize}" -lt $minBufferSize ]
then
    MPI_BUFFER_SIZE=$minBufferSize
fi
export MPI_BUFFER_SIZE

if [ -n "$WM_USE_MACPORT" ]
then
    if [ -e "/opt/local/include/mpfr.h" ]
    then
	export MPFR_ARCH_PATH=/opt/local
	unset MPFR_VERSION
    else
	echo "No mpfr in MacPorts. Install mpfr with 'port install mpfr'"
    fi
    if [ -e "/opt/local/include/gmp.h" ]
    then
	export GMP_ARCH_PATH=/opt/local
	unset GMP_VERSION
    else
	echo "No gmp in MacPorts. Install gmp with 'port install gmp'"
    fi
fi

# cleanup environment:
# ~~~~~~~~~~~~~~~~~~~~
#keep _foamAddPath _foamAddLib _foamAddMan
unset foamCompiler minBufferSize

# ----------------------------------------------------------------- end-of-file
