#!/bin/bash
#   this script should be copied in 'Run Script' phase in 'Build Phases' tab on Cocaravis target.
#   the script performs library paths embedded in dylib binaries to '@loader_path/Frameworks'
#   the script is refered that described in
#   https://qiita.com/Nunocky/items/d6c1f820a94d910cb5a0
#   or some other sites.
#   thank authors for reporting the articles.

EXECFILE=${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}
LIBPATH=${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
NEWLIBPATH=@loader_path/Frameworks

cd ${LIBPATH}
TARGETS=(`ls -w *.dylib`)

for TARGET in ${TARGETS[@]}
do
    LIBFILE=${LIBPATH}/${TARGET}
    TARGETID=`otool -DX "${TARGET}"`
    NEWTARGETID=${NEWLIBPATH}/${TARGET}
    install_name_tool -id "${NEWTARGETID}" "${LIBFILE}"
    install_name_tool -change ${TARGETID} ${NEWTARGETID} "${EXECFILE}"
done

for TARGET in ${TARGETS[@]}
do
    for LIB in ${TARGETS[@]}
    do
        if [ ${TARGET} != ${LIB} ]
        then
            REFLIBS=(`otool -LX $TARGET | grep $LIB`)
            if [ ${#REFLIBS[0]% *} -gt 0 ]
            then
                NEWLIBID=@rpath/${LIB}
                install_name_tool -change ${REFLIBS} ${NEWLIBID} ${TARGET}
            fi
        fi
    done
done

#   trying to use macOS ffi but falied. I don't know why.
##OLDFFIAPTH=`otool -LX libgobject-2.0.0.dylib | grep libffi
##install_name_tool -change ${OLDFFIAPTH%% *} /usr/lib/libffi.dylib libgobject-2.0.0.dylib

##ln -s ${LIBPATH} ../../../Frameworks
