#author: Xuanvt
#date: 01/Aug/18

#prepared file: CodeSourcery and ti-ezsdk-dm8168

#############################################################################
#	Fix bugs not found python 3.6 when sfdisk installed
#############################################################################
sudo add-apt-repository ppa:jonathonf/python-3.6  # (only for 16.04 LTS)
sudo apt update
sudo apt install python3.6
sudo apt install python3.6-dev
sudo apt install python3.6-venv
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.6 get-pip.py
sudo ln -s /usr/bin/python3.6 /usr/local/bin/python3
sudo ln -s /usr/local/bin/pip /usr/local/bin/pip3

#############################################################################
#	Fix bugs downgrade sfdisk 2.25
#############################################################################
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/util-linux/2.25.2-4ubuntu3/util-linux_2.25.2.orig.tar.xz

tar xvf util-linux_2.25.2.orig.tar.xz
cd util-linux_2.25.2/
./autogen.sh
./configure
make
pwd
#############################################################################
#java.lang.UnsatisfiedLinkError: /tmp/install.dir.8756/Linux/resource/jre/lib/i386/xawt/libmawt.so: libXext.so.6
#############################################################################
sudo apt-get install libxrender1:i386 libxtst6:i386 libxi6:i386

#############################################################################
#	Build bootloader, kernel, filesystem DM8168
#############################################################################

export PATH=/home/l/CodeSourcery/Sourcery_G++_Lite/bin:$PATH
export PATH=/home/l/ti-ezsdk_dm816x-evm_5_05_02_00/board-support/u-boot-2010.06-psp04.04.00.01/tools:$PATH

#build u-boot
cd /home/l/ti-ezsdk_dm816x-evm_5_05_02_00/board-support/u-boot-2010.06-psp04.00.00.12
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm distclean
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm ti8168_evm_min_sd
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm u-boot.ti
cp u-boot.min.sd ../host-tools/MLO
cp u-boot.bin ../host-tools

#build kernel
cd ../linux-2.6.37-psp04.00.00.12
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm distclean
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm ti8168_evm_defconfig
make CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm uImage
cp arch/arm/boot/uImage ../host-tools

#if failed kernel/timeconst.pl line 373 => change !define(@val) => !@val

#setup filesystem
cd ~/
ti-ezsdk_dm816x-evm_5_05_02_00/setup.sh
cd targetfs/
sudo tar czvf ../nfs.tar.gz *
cp nfs.tar.gz ti-ezsdk_dm816x-evm_5_05_02_00/board-support/host-tools/

cd /home/l/ti-ezsdk_dm816x-evm_5_05_02_00/board-support/host-tools
gedit mksd-ti816x.sh
#Copy path sfdisk
#edit mksd-ti816x.sh path sfdisk

#Build all apps and compo
cd /home/l/ti-ezsdk_dm816x-evm_5_05_02_00
#change content in the makefile: remove matrix psp-examples
make all
sudo make install


sudo ./mksd-ti816x.sh /dev/sdb MLO u-boot.bin uImage nfs.tar.gz

