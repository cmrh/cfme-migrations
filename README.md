# cfme-migrations
############
# Migration scripts
############
Used for dumping all vm attributes to a file and loading the attributes back to cloudforms vmdb.
Use case is for a vcenter migration where the data on vcenter is not exported from the old vcenter to the new one.
This results in a new UUID's being created and to ManageIQ/Cloudforms, they all look like new VMs. All attributes created for
the VM's before will then be lost. 

dump_attrs - shell script to run rails and dump_vm_attrs.rb and dump the attributes to a file
load_attrs - shell script to run rails and load_vm_attrs.rb and load the vm attributes to the vmdb
dump_vm_attrs.rb - Ruby script run by rails
load_vm_attrs.rb - Ruby script run by rails

#############
#Instructions
#############
- Unzip the contents of the zip file to /root/migration-stuff/
- Create /root/migration-stuff/tmp if it doesn't exist
- If you want to change the location of the saved attributes file, feel free to edit the ruby files.
- Before the vcenter migration, run the dump_attrs script to dump all current VM attriutes to a file
- After the migration is complete, wait for the VMs have been rediscovered by Cloudforms. 
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
You may want to test before an actual live migration ( these don't happen everyday ).
Artificial conditions will have to be created to test.
- Run the dump_attrs script
- Pick a vm and delete all tags and change ownership to admin ( anything random tbh )
- Run load_attrs script
