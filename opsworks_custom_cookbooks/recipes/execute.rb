Chef::Log.info "OpsWorks Custom Run List: #{node[:opsworks_custom_cookbooks][:recipes].inspect}"

ruby_block("Compile Custom OpsWorks Run List") do
  block do
    begin

      # Reload cookbooks after they're available on local filesystem
      cl = Chef::CookbookLoader.new(Chef::Config[:cookbook_path])
      cl.load_cookbooks
      self.run_context.instance_variable_set(:@cookbook_collection, Chef::CookbookCollection.new(cl))

      # Expand run list with custom cookbooks and load them into the current run_context
      override_run_list = node[:run_list_override] || {}
      recipe_run_list = node[:opsworks_custom_cookbooks][:recipes].dup.to_a

      override_run_list.each do |override_recipe, data|
        # Grab the direction (before/after) and recipe to look for
        data.each do |direction, recipe_list|
          next unless %w{ before after }.include?(direction)

          if override_index = recipe_run_list.index { |x| x == override_recipe }
            recipe_list.each do |recipe|
              if new_index = recipe_run_list.index { |x| x == recipe }
                # Remove override recipe from recipe_run_list
                recipe_run_list.slice!(override_index)

                # Insert override recipe into correct position in recipe_run_list
                new_index += 1 if direction == 'after'
                recipe_run_list.insert(new_index, override_recipe)
              end
            end
          end
        end
      end

      opsworks_run_list = Chef::RunList.new(*recipe_run_list)
      Chef::Log.info "New Run List expands to #{opsworks_run_list.run_list_items.map(&:name).inspect}"
      self.run_context.load(opsworks_run_list)

    rescue Exception => e
      Chef::Log.error "Caught exception while compiling OpsWorks custom run list: #{e.class} - #{e.message} - #{e.backtrace.join("\n")}"
      raise e
    end

  end
end
