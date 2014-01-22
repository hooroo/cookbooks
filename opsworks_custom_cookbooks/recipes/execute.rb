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
        data.each do |direction, recipe_list_to_search_for|
          next unless %w{ before after }.include?(direction)

          if index_of_recipe_to_move = recipe_run_list.index { |x| x == override_recipe }

            recipe_list_to_search_for.each do |r|

              index_of_recipe_in_run_list = recipe_run_list.index { |x| x == r }

              # Only fiddle with the run list if the order is not already correct
              #
              if index_of_recipe_in_run_list
                index_of_recipe_in_run_list += 1 if direction == 'after'

                if index_of_recipe_in_run_list != index_of_recipe_to_move

                  # Insert override recipe into correct position in recipe_run_list
                  recipe_run_list.insert(index_of_recipe_in_run_list, override_recipe)

                  # Remove override recipe from recipe_run_list
                  index_of_recipe_to_move += 1 if index_of_recipe_to_move > index_of_recipe_in_run_list
                  recipe_run_list.slice!(index_of_recipe_to_move)
                end

                break
              end
            end
          end
        end
      end

      opsworks_run_list = Chef::RunList.new(*recipe_run_list)
      Chef::Log.info "NEW Run List expands to #{opsworks_run_list.run_list_items.map(&:name).inspect}"
      self.run_context.load(opsworks_run_list)

    rescue Exception => e
      Chef::Log.error "Caught exception while compiling OpsWorks custom run list: #{e.class} - #{e.message} - #{e.backtrace.join("\n")}"
      raise e
    end

  end
end
