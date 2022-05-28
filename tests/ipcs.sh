#!/bin/sh
if [ $# -lt 1 ]; then
	echo "Syntax: $0 <dump dataset>" >&2
	exit 4
fi
dump_ds="$1"

systsin=$(mvstmp `hlq`)
dtouch -tseq -rfb -l80 "${systsin}"
decho " 
 PROFILE MSGID
 ALLOC FI(SYSPROC) DA('SYS1.SBLSCLI0')
 %BLSCDDIR VOLUME (USERS)
 IPCS NOPARM
 SETDEF DSN('${dump_ds}') NOCONFIRM
 VERBEXIT SUMDUMP" "${systsin}"

systsprt=$(mvstmp `hlq`)
dtouch -tseq -rvba -l137 "${systsprt}"
ipcsprnt=$(mvstmp `hlq`)
dtouch -tseq -rvba -l137 "${ipcsprnt}"
ipcstoc=$(mvstmp `hlq`)
dtouch -tseq -rvba -l137 "${ipcstoc}"
sysudump=$(mvstmp `hlq`)
dtouch -tseq -rvba -l137 "${sysudump}"

mvscmdauth -v --pgm=ikjeft01 --dump="${dump_ds}" --systsprt="${systsprt}" --ipcsprnt="${ipcsprnt}" --ipcstoc="${ipcstoc}" --sysudump="${sysudump}" --systsin="${systsin}"

if false; then
	echo "SYSTSIN: ${systsin}"
	echo "SYSTSPRT: ${systsprt}"
	echo "IPCSPRNT: ${ipcsprnt}"
	echo "IPCSTOC: ${ipcstoc}"
	echo "SYSUDUMP: ${sysudump}"
fi

cat "//'${systsprt}'"
drm "${systsin}" "${systsprt}" "${ipcsprnt}" "${ipcstoc}" "${sysudump}"
