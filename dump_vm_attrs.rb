###################################
# CFME: dump_vm_attrs.rb
# Notes: Dump out VM attributes and write the data to a file.
#
###################################

$evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)

begin
  # Method for logging
  def log(level, message)
    @method = 'dump_vm_attrs'
    puts "#{@method} - #{message}"
  end

  #################################
  # Method: writeToFile
  # Notes: puts each vm in a new line
  #################################
  def writeToFile(target, aLine)
    target.puts(aLine)
  end

  log(:info, "Method Started")

  # Open file
  filetarget = File.open("/root/migration-stuff/tmp/attrs_vm.data", "w+")


  # get vm information to send
  $evm.vmdb('vm').all.each do |v|

    vm_name = v.name

    #vm_prov = v.miq_provision

    vm_group = v.miq_group_id

    vm_owner = v.owner

    if vm_owner.nil?
      log(:info, "NilOwner: #{vm_name}")
      vm_userid = nil
    else
      vm_userid = vm_owner.userid
    end

    vm_retires_on = v.retires_on
    if vm_retires_on.nil?
      log(:info, "NilRetirement: #{vm_name}")
    end

    vm_tags = v.tags
    vm_tags.delete_if { |tag| tag.include? 'folder_path_yellow' }
    vm_tags.delete_if { |tag| tag.include? 'folder_path_blue' }
    vm_tags_str = vm_tags.join(',')

    # Pull the status of the VM

    vm_retired = v.retired
    vm_orphaned = v.orphaned
    vm_archived = v.archived

    # Write to file, unless the VM is in state retired, archived or orphaned

    if vm_retired == nil and vm_orphaned == false and vm_archived == false
    writeToFile(filetarget, "vm_name=#{vm_name}|vm_owner=#{vm_userid}|vm_tags=#{vm_tags_str}|vm_retires_on=#{vm_retires_on}|vm_group=#{vm_group}")
    end

  end

  # Close file
  filetarget.close

  # Exit method
  log(:info, "Method Ended")
  exit

    # Set Ruby rescue behavior
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit
  end

