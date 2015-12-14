# cfme-migrations
############
# Migration scripts
############
The scripts attached are used for dumping all vm attributes to a file and loading the attributes back to the vmdb.

dump_attrs - shell script to run rails and dump_vm_attrs.rb and dump the attributes to a file
load_attrs - shell script to run rails and load_vm_attrs.rb and load the vm attributes to the vmdb
dump_vm_attrs.rb - Ruby script run by rails
load_vm_attrs.rb - Ruby script run by rails

#############
#Instructions
#############
- Unzip the contents of the zip file to /root/migration-stuff/
- Create /root/migration-stuff/tmp if it doesn't exist
- Before the vcenter migration, run the dump_attrs script to dump all current VM attriutes to a file
- It is advisable to avoid deploying any more VM's during the migration. If a VM with a similar name is created after
  the migration script is run, the new VM's attributes will be over written by the old attributes dumped. Basically
  a race condition could be advertently created.
- After the migration is complete, make sure the VMs have been rediscovered by Cloudforms. If the uuid for the VM's
  has not changed on vcenter, all attributes should still be intact on Cloudforms.
- If the UUID for the VMs changed on vcenter, the rediscovered VM's will be missing attributes. Run the load_attrs
  script which will read the file created by the dump_attrs script and copy each VM's attributes to the vmdb.

############
# Notes
############
- As is, the ruby scripts will only dump VM attributes. To include templates, change the following section in dump_vm_attrs.rb

  $evm.vmdb('vm').all.each do |v|

to

  $evm.vmdb(:VmOrTemplate).all.each do |v|

Edit load_vm_attrs.rb and change the following section

  vm = $evm.vmdb('vm').find_by_name(vm_name)

to

 vm = $evm.vmdb(:VmOrTemplate).find_by_name(vm_name)

###########
# Testing methodology
###########
There was no actual migration happenning during the testing of the script so artificial conditions needed to be created.
- Run the dump_attrs script
- Pick a vm and delete all tags and change ownership to admin ( anything random tbh )
- Run load_attrs script
