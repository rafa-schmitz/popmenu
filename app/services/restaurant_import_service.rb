class RestaurantImportService
  class ImportError < StandardError; end
  class ValidationError < ImportError; end

  def initialize(json_data)
    @json_data = json_data
    @logs = []
    @success_count = 0
    @error_count = 0
  end

  def import
    validate_json_structure
    process_restaurants
    build_result
  rescue => e
    log_error("Import failed: #{e.message}")
    build_result
  end

  private

  attr_reader :json_data, :logs, :success_count, :error_count

  def validate_json_structure
    unless json_data.is_a?(Hash) && json_data["restaurants"].is_a?(Array)
      raise ValidationError, "Invalid JSON structure. Expected 'restaurants' array."
    end

    if json_data["restaurants"].empty?
      raise ValidationError, "No restaurants found in JSON data."
    end
  end

  def process_restaurants
    json_data["restaurants"].each do |restaurant_data|
      process_restaurant(restaurant_data)
    end
  end

  def process_restaurant(restaurant_data)
    restaurant_name = restaurant_data["name"]
    return log_error("Restaurant name is required") if restaurant_name.blank?

    restaurant = find_or_create_restaurant(restaurant_name)
    process_menus(restaurant, restaurant_data["menus"] || [])
  rescue => e
    log_error("Failed to process restaurant '#{restaurant_name}': #{e.message}")
  end

  def find_or_create_restaurant(name)
    Restaurant.find_or_create_by(name: name.strip) do |restaurant|
      log_info("Created new restaurant: #{name}")
    end
  end

  def process_menus(restaurant, menus_data)
    menus_data.each do |menu_data|
      process_menu(restaurant, menu_data)
    end
  end

  def process_menu(restaurant, menu_data)
    menu_name = menu_data["name"]
    return log_error("Menu name is required") if menu_name.blank?

    menu = find_or_create_menu(restaurant, menu_name)
    process_menu_items(restaurant, menu, menu_data)
  rescue => e
    log_error("Failed to process menu '#{menu_name}': #{e.message}")
  end

  def find_or_create_menu(restaurant, name)
    restaurant.menus.find_or_create_by(name: name.strip) do |menu|
      log_info("Created new menu '#{name}' for restaurant '#{restaurant.name}'")
    end
  end

  def process_menu_items(restaurant, menu, menu_data)
    # Handle both 'menu_items' and 'dishes' keys
    items_data = menu_data["menu_items"] || menu_data["dishes"] || []

    items_data.each do |item_data|
      process_menu_item(restaurant, menu, item_data)
    end
  end

  def process_menu_item(restaurant, menu, item_data)
    item_name = item_data["name"]
    item_price = item_data["price"]

    return log_error("Menu item name is required") if item_name.blank?
    return log_error("Menu item price is required") if item_price.blank?

    # Normalize price
    price = normalize_price(item_price)
    return log_error("Invalid price format for '#{item_name}': #{item_price}") if price.nil?

    # Find or create menu item
    menu_item = find_or_create_menu_item(restaurant, item_name, price)

    # Associate with menu if not already associated
    unless menu.menu_items.include?(menu_item)
      menu.menu_items << menu_item
      log_info("Associated menu item '#{item_name}' with menu '#{menu.name}'")
    end

    @success_count += 1
  rescue => e
    log_error("Failed to process menu item '#{item_name}': #{e.message}")
    @error_count += 1
  end

  def find_or_create_menu_item(restaurant, name, price)
    # Check if menu item already exists for this restaurant (case-insensitive)
    existing_item = restaurant.menu_items.find_by("LOWER(name) = ?", name.strip.downcase)

    if existing_item
      # Update price if different
      if existing_item.price != price
        existing_item.update!(price: price)
        log_info("Updated price for existing menu item '#{name}' from #{existing_item.price} to #{price}")
      end
      existing_item
    else
      # Create new menu item
      menu_item = MenuItem.create!(name: name.strip, price: price, restaurant: restaurant)
      log_info("Created new menu item '#{name}' with price #{price}")
      menu_item
    end
  end

  def normalize_price(price)
    case price
    when Numeric
      price.to_f
    when String
      price.gsub(/[^\d.]/, "").to_f
    else
      nil
    end
  rescue
    nil
  end

  def log_info(message)
    logs << { level: "info", message: message, timestamp: Time.current }
    Rails.logger.info("RestaurantImport: #{message}")
  end

  def log_error(message)
    logs << { level: "error", message: message, timestamp: Time.current }
    Rails.logger.error("RestaurantImport: #{message}")
    @error_count += 1
  end

  def build_result
    {
      success: error_count == 0,
      total_processed: success_count + error_count,
      success_count: success_count,
      error_count: error_count,
      logs: logs
    }
  end
end
