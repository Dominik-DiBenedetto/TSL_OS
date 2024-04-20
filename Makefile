GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS  = --32
LDPARAMS  = -melf_i386

objects   = loader.o kernel.o

%.o: %.cpp # make .o file from .cpp; $@ is target file, $< is input file
	g++ $(GPPPARAMS) -o $@ -c $< 

%.o: %.s # make .o file from .s
	as $(ASPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin

mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp $< iso/boot/

	echo 'set timeout=0' >> iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo '' >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Awesomesauce Operating System" {' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso/boot/grub/grub.cfg
	echo '	boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg

	grub-mkrescue --output=$@ iso
	rm -rf iso

run: mykernel.iso
	vboxmanage startvm "tsl os" 
#qemu-system-x86_64 -enable-kvm -m 4G -smp 2 -boot d -cdrom $< -netdev user,id=net0,net=192.168.0.0/24,dhcpstart=192.168.0.9 -device virtio-net-pci,netdev=net0 -vga qxl -device AC97

#### ALTERNATIVE VM METHOD ####
#qemu-system-x86_64 -enable-kvm -m 4G -smp 2 -boot d -cdrom mykernel.iso -netdev user,id=net0,net=192.168.0.0/24,dhcpstart=192.168.0.9 -device virtio-net-pci,netdev=net0 -vga qxl -device AC97