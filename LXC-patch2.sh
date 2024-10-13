#! /bin/bash 
echo "######LXC的一键补丁脚本2，使用方法确保utils文件夹在内核源码目录下，修改export KD=vendor/cmi_user_defconfig或当前终端直接 export KD=xxxxx_defconfig或export KD=vendor/xxxxx_defconfig，xxxxx_defconfig为你机型的内核配置并运行此脚本，然后按一般方式构建内核######"
echo "           "

#手机的内核配置文件(KERNEL_DEFCONFIG简称KD，一般在内核源码目录下的arch/arm64/configs或arch/arm64/configs/vendor下，一般为机型代号，高通骁龙处理器代号啥的，比如mi5 的为gemini_defconfig,一加8系列为kona_pref_defconfig,按实际情况修改
#export KD=vendor/cmi_user_defconfig

#KD=vendor/xxxx_defconfig或KD=xxxx_defconfig                                        
echo " -----------------------------------------------------------------------------"
echo "----------------   你设置的内核配置文件为:$KD   ----------------"
echo " -----------------------------------------------------------------------------"

                                   
export GKI_ROOT=$(pwd)

echo "         "
echo "#添加LXC配置到内核"
echo "         "
cp /root/Toolchain/utils $GKI_ROOT/ -R
cp /root/Toolchain/LXC-DOCKER-OPEN-CONFIG.sh $GKI_ROOT
chmod +x *.sh
cp ./arch/arm64/configs/$KD ./arch/arm64/configs/kernel-`date '+%Y%m%d%H%M%S'`_defconfig
echo "---------------- 此脚本会强制修改$KD,所以已经重新备份原$KD到 arch/arm64/configs/kernel-`date '+%Y%m%d%H%M%S'`_defconfig ----------"
sh $GKI_ROOT/LXC-DOCKER-OPEN-CONFIG.sh $GKI_ROOT/arch/arm64/configs/${KD} -w

sed -i '/CONFIG_ANDROID_PARANOID_NETWORK/d' "$GKI_ROOT/arch/arm64/configs/${KD}"

echo "# CONFIG_ANDROID_PARANOID_NETWORK is not set" >> "$GKI_ROOT/arch/arm64/configs/${KD}"

sed -i '/CONFIG_LOCALVERSION/d' "$GKI_ROOT/arch/arm64/configs/${KD}"

echo 'CONFIG_LOCALVERSION="-LXC-support_Pdx"' >> "$GKI_ROOT/arch/arm64/configs/${KD}"

echo "         "
echo "         "
echo "#运用LXC相关补丁"
echo "         "
echo "         "

if [ -f $GKI_ROOT/kernel/cgroup/cgroup.c ]; then
      sh $GKI_ROOT/utils/runcpatch.sh $GKI_ROOT/kernel/cgroup/cgroup.c
fi

if [ -f $GKI_ROOT/kernel/cgroup.c ]; then
      sh $GKI_ROOT/utils/runcpatch.sh $GKI_ROOT/kernel/cgroup.c
fi

if [ -f $GKI_ROOT/net/netfilter/xt_qtaguid.c ]; then
       patch -p0 < $GKI_ROOT/utils/xt_qtaguid.patch
fi

echo "         "
echo "运用补丁完成，请按一般方式构建内核"
echo "         "
