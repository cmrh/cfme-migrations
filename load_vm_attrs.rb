###################################
# CFME Method: load_vm_attrs.rb
# Notes: This method loads vm attributes from a file and writes them to the vmdb IF
# AND ONLY IF the attribute for the vm is nil
###################################

$evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)

begin
  # Method for logging
  def log(level, message)
    @method = 'load_vm_attrs'
    $evm.log(level, "#{@method} - #{message}")
  end

  def tag_vm (vm, category_name, tag_name)
    if vm.tagged_with?(category_name,tag_name)
    else
      vm.tag_assign("#{category_name}/#{tag_name}")
    end
  end

  def openFile(filename)
    return File.open(filename, 'r')
  end

  def closeFile(file)
    file.close
  end

  def assign_vm_owner(vm, owner, vm_group)
    unless owner.nil? || owner.empty?
      log(:info, "Assign: VM #{vm.name} has owner #{owner}")
      owner_obj = $evm.vmdb('user').find_by_userid(owner)

      unless owner_obj.nil?

        vm.owner = owner_obj

        group_obj = owner_obj.miq_group
        miq_group_id = group_obj.id
        log(:info, "Assign: VM #{vm.name} has group obj id #{group_obj.id} #{miq_group_id}")

        vm.group = group_obj
      end

    end
  end

  def assign_vm_tags(vm, tags)
    unless tags.nil? || tags.empty?
      tagsArray = tags.split(',')

      tagsArray.each do |tag|
        category, tag_value = tag.split('/')
        tag_vm(vm, category,tag_value)
        log(:info, "Assign: VM #{vm.name} has Cat: #{category} and Tag: #{tag_value}")
      end
    end
  end

  def assign_vm_retires_on(vm, retires_on)
    unless retires_on.nil? || retires_on.empty?
      log(:info, "Assign: VM #{vm.name} has retirement #{retires_on}")
      vm.retires_on = retires_on
    end
  end

  log(:info, "Method Started")

  # Open file
  src_file = openFile("/root/migration-stuff/tmp/attrs_vm.data")

  src_file.each do | aLine |

      aLineArray = aLine.chomp.split('|')
      vm_name = aLineArray[0].split('=')[1]
      vm_owner = aLineArray[1].split('=')[1]
      vm_tags = aLineArray[2].split('=')[1]
      vm_retires_on = aLineArray[3].split('=')[1]
      vm_group = aLineArray[4].split('=')[1]

      vm = $evm.vmdb('vm').find_by_name(vm_name)
      unless vm.nil?
        vm_retired = vm.retired
        vm_orphaned = vm.orphaned
        vm_archived = vm.archived
 
        if vm_retired == nil and vm_orphaned == false and vm_archived == false 
           log(:info, "VM = #{vm_name}")
           assign_vm_owner(vm, vm_owner, vm_group)
           assign_vm_tags(vm, vm_tags)
           assign_vm_retires_on(vm, vm_retires_on)
        end
      end
  end

  # Close file
  closeFile(src_file)

  log(:info, "Method Ended")
  exit

rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit 
end
