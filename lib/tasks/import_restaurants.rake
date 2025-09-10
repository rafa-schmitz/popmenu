namespace :restaurants do
  desc "Import restaurant data from JSON file"
  task :import, [ :file_path ] => :environment do |task, args|
    file_path = args[:file_path]

    unless file_path
      puts "Usage: rails restaurants:import[path/to/restaurant_data.json]"
      puts "Example: rails restaurants:import[data/restaurant_data.json]"
      exit 1
    end

    unless File.exist?(file_path)
      puts "Error: File '#{file_path}' not found."
      exit 1
    end

    begin
      puts "Starting import from #{file_path}..."
      json_data = JSON.parse(File.read(file_path))

      service = RestaurantImportService.new(json_data)
      result = service.import

      puts "\n=== Import Results ==="
      puts "Success: #{result[:success] ? 'YES' : 'NO'}"
      puts "Total processed: #{result[:total_processed]}"
      puts "Success count: #{result[:success_count]}"
      puts "Error count: #{result[:error_count]}"

      puts "\n=== Logs ==="
      result[:logs].each do |log|
        timestamp = log[:timestamp].strftime("%Y-%m-%d %H:%M:%S")
        level = log[:level].upcase
        puts "[#{timestamp}] #{level}: #{log[:message]}"
      end

      if result[:success]
        puts "\n✅ Import completed successfully!"
        exit 0
      else
        puts "\n❌ Import completed with errors."
        exit 1
      end

    rescue JSON::ParserError => e
      puts "Error: Invalid JSON format - #{e.message}"
      exit 1
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Import restaurant data from provided sample JSON"
  task import_sample: :environment do
    sample_json = {
      "restaurants" => [
        {
          "name" => "Poppo's Cafe",
          "menus" => [
            {
              "name" => "lunch",
              "menu_items" => [
                {
                  "name" => "Burger",
                  "price" => 9.00
                },
                {
                  "name" => "Small Salad",
                  "price" => 5.00
                }
              ]
            },
            {
              "name" => "dinner",
              "menu_items" => [
                {
                  "name" => "Burger",
                  "price" => 15.00
                },
                {
                  "name" => "Large Salad",
                  "price" => 8.00
                }
              ]
            }
          ]
        },
        {
          "name" => "Casa del Poppo",
          "menus" => [
            {
              "name" => "lunch",
              "dishes" => [
                {
                  "name" => "Chicken Wings",
                  "price" => 9.00
                },
                {
                  "name" => "Burger",
                  "price" => 9.00
                },
                {
                  "name" => "Chicken Wings",
                  "price" => 9.00
                }
              ]
            },
            {
              "name" => "dinner",
              "dishes" => [
                {
                  "name" => "Mega \"Burger\"",
                  "price" => 22.00
                },
                {
                  "name" => "Lobster Mac & Cheese",
                  "price" => 31.00
                }
              ]
            }
          ]
        }
      ]
    }

    begin
      puts "Starting import from sample data..."

      service = RestaurantImportService.new(sample_json)
      result = service.import

      puts "\n=== Import Results ==="
      puts "Success: #{result[:success] ? 'YES' : 'NO'}"
      puts "Total processed: #{result[:total_processed]}"
      puts "Success count: #{result[:success_count]}"
      puts "Error count: #{result[:error_count]}"

      puts "\n=== Logs ==="
      result[:logs].each do |log|
        timestamp = log[:timestamp].strftime("%Y-%m-%d %H:%M:%S")
        level = log[:level].upcase
        puts "[#{timestamp}] #{level}: #{log[:message]}"
      end

      if result[:success]
        puts "\n✅ Sample import completed successfully!"
      else
        puts "\n❌ Sample import completed with errors."
      end

    rescue => e
      puts "Error: #{e.message}"
    end
  end
end
