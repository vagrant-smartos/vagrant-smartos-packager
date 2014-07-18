
#
# Site for SmartOS platform image
#
readonly LATEST_SMARTOS_PATH=$(curl --silent "https://us-east.manta.joyent.com/Joyent_Dev/public/SmartOS/latest")
readonly DLSITE="https://us-east.manta.joyent.com${LATEST_SMARTOS_PATH}"


#
# Find a suitable md5sum program.
#
if type md5 >/dev/null 2>&1; then
    md5sum='md5'
    column='NF'
elif type digest >/dev/null 2>&1 &&
     digest md5 /dev/null >/dev/null 2>&1; then
    md5sum='digest md5'
    column='NF'
elif type digest >/dev/null 2>&1 &&
     digest -a md5 /dev/null >/dev/null 2>&1; then
    md5sum='digest -a md5'
    column='1'
elif type md5sum >/dev/null 2>&1; then
    md5sum='md5sum'
    column='1'
elif type openssl >/dev/null 2>&1 &&
     openssl md5 -hex /dev/null >/dev/null 2>&1; then
    md5sum='openssl md5 -hex'
    column='NF'
else
    echo "ERROR: Sorry, could not find an md5 program" 1>&2
    exit 1
fi

function vbox_machine_folder {
  echo $(VBoxManage list systemproperties \
            | awk '/^Default.machine.folder/ { print $4 }')
}

function clear_smartos_sums {
  rm tmp/smartos-sums.txt
}

#
# Download MD5 file for latest image
#
function require_smartos_sums {
  if [ ! -d tmp ]; then
    echo "creating tmp dir" >&2
    mkdir -p tmp
  fi

  if [ ! -e tmp/smartos-sums.txt ]; then
    echo "Downloading smartos sum" >&2
    curl --silent -o tmp/smartos-sums.txt ${DLSITE}/md5sums.txt 2>/dev/null
  fi
}

function smartos_md5 {
  require_smartos_sums
  echo $(awk '/\.iso/ { print $1 }' tmp/smartos-sums.txt)
}

function smartos_version {
  local md5=$(smartos_md5)
  echo $(sed -ne "/^${md5}/s/.*-\(.*\).iso/\1/p" \
                    tmp/smartos-sums.txt)
}

function smartos_vmname {
  local version=$(smartos_version)
  echo "SmartOS-${version}"
}

function smartos_ISO_path {
  local vboxdir=$(vbox_machine_folder)
  local vmname=$(smartos_vmname)
  local smartos_version=$(smartos_version)

  echo "${vboxdir}/${vmname}/${smartos_version}.iso"
}

function download_smartos_ISO {
  local vboxdir=$(vbox_machine_folder)
  local vmname=$(smartos_vmname)
  local smartos_version=$(smartos_version)
  local smartos_md5=$(smartos_md5)

  local iso_path=$(smartos_ISO_path)

  mkdir -p "${vboxdir}/${vmname}"
  if [ ! -f "${iso_path}" ]; then
    echo "Downloading ${DLSITE}/${smartos_version}.iso"
    curl -o ${iso_path} \
            ${DLSITE}/smartos-${smartos_version}.iso
    dl_md5=$(${md5sum} "${iso_path}" \
               | awk '{ print $'${column}' }')
    if [ -z "${dl_md5}" ]; then
      echo "ERROR: Couldn't fetch ISO image"
      exit 1
    fi
    if [ "${smartos_md5}" != "${dl_md5}" ]; then
      echo "ERROR: md5 checksums do not match"
      exit 1
    fi
  fi

  echo "Current SmartOS platform image : ${smartos_version}" >&2
  echo "                        md5sum : ${smartos_md5}" >&2
}

function create_smartos_VM {
  local disk_size=$1
  local mem_size=$2
  local ssh_port=$3

  local vboxdir=$(vbox_machine_folder)
  local vmname=$(smartos_vmname)
  local smartos_version=$(smartos_version)

  echo "Creating/Updating Virtual Machine" >&2
  echo "  disk size   : ${disk_size} GB" >&2
  echo "  memory size : ${mem_size} MB" >&2
  echo "  ssh port    : ${ssh_port}" >&2

  VBoxManage showvminfo "${vmname}" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # VM already exists, just update the ISO image
    VBoxManage storageattach "${vmname}" --storagectl "IDE Controller" \
      --port 1 --device 0 --type dvddrive \
      --medium "${vboxdir}/${vmname}/${smartos_version}.iso"
  else
    # Create the VM
    VBoxManage createvm --name "${vmname}" --ostype OpenSolaris_64 --register
    VBoxManage storagectl "${vmname}" --name "IDE Controller" --add ide

    # Attach the ISO image
    VBoxManage storageattach "${vmname}" --storagectl "IDE Controller" \
      --port 1 --device 0 --type dvddrive \
      --medium "${vboxdir}/${vmname}/${smartos_version}.iso"

    # Create and attach the zone disk
    VBoxManage createhd --filename "${vboxdir}/${vmname}/smartos-zones.vdi" \
      --size $(echo "${disk_size}*1024" | bc)
    VBoxManage storageattach "${vmname}" --storagectl "IDE Controller" \
      --port 0 --device 0 --type hdd \
      --medium "${vboxdir}/${vmname}/smartos-zones.vdi"

    # Set misc settings
    VBoxManage modifyvm "${vmname}" --boot1 dvd --boot2 disk --boot3 none
    VBoxManage modifyvm "${vmname}" --memory ${mem_size}
    VBoxManage modifyvm "${vmname}" --natpf1 "SSH,tcp,,${ssh_port},,22"
  fi
}
