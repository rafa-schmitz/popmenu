# PopMenu Restaurant API

A Rails API application for managing restaurant menus and menu items. This application provides endpoints to import restaurant data, view restaurants, menus, and menu items.

## Features

- **Restaurant Management**: Create and view restaurants
- **Menu Management**: Handle multiple menus per restaurant
- **Menu Item Management**: Manage menu items with pricing
- **Data Import**: Import restaurant data from JSON files via API or rake tasks
- **RESTful API**: Clean API endpoints for all operations

## Prerequisites

- Ruby 3.4.5
- PostgreSQL
- Bundler

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd popmenu
bundle install
```

### 2. Database Setup

The application uses PostgreSQL. Make sure PostgreSQL is running and create the databases:

```bash
# Create and setup the database
rails db:create
rails db:migrate
```

### 3. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Restaurants
- `GET /api/restaurants` - List all restaurants
- `GET /api/restaurants/:id` - Get a specific restaurant

### Menus
- `GET /api/menus` - List all menus
- `GET /api/menus/:id` - Get a specific menu

### Menu Items
- `GET /api/menu_items` - List all menu items

### Data Import
- `POST /api/imports` - Import restaurant data from JSON

## Testing the Application

### 1. Run the Test Suite

```bash
bundle exec rspec
```

This will run all RSpec tests including:
- Controller tests for API endpoints
- Service tests for import functionality
- Model tests for data validation

### 2. Manual Testing with Sample Data

#### Import Sample Data via Rake Task

```bash
rails restaurants:import_sample
```

#### Import Sample Data via API

Create a file called `sample_data.json`:

```json
{
  "restaurants": [
    {
      "name": "Poppo's Cafe",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            {"name": "Burger", "price": 9.00},
            {"name": "Small Salad", "price": 5.00}
          ]
        },
        {
          "name": "dinner",
          "menu_items": [
            {"name": "Burger", "price": 15.00},
            {"name": "Large Salad", "price": 8.00}
          ]
        }
      ]
    }
  ]
}
```

Then import it:

```bash
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d @sample_data.json
```

### 3. Test API Endpoints

After importing data, test the endpoints:

```bash
# List all restaurants
curl http://localhost:3000/api/restaurants

# Get a specific restaurant
curl http://localhost:3000/api/restaurants/1

# List all menus
curl http://localhost:3000/api/menus

# List all menu items
curl http://localhost:3000/api/menu_items
```

### 4. Test Import Functionality

#### Test with different JSON formats:

**Standard format (menu_items):**
```bash
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d '{"restaurants": [{"name": "Test Restaurant", "menus": [{"name": "lunch", "menu_items": [{"name": "Burger", "price": 9.99}]}]}]}'
```

**Alternative format (dishes):**
```bash
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d '{"restaurants": [{"name": "Test Restaurant 2", "menus": [{"name": "dinner", "dishes": [{"name": "Pasta", "price": 12.50}]}]}]}'
```

#### Test file upload:
```bash
curl -X POST http://localhost:3000/api/imports \
  -F "file=@sample_data.json"
```

### 5. Test Error Handling

Test various error scenarios:

```bash
# Invalid JSON
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d 'invalid json'

# Empty request
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Development

### Running Tests

```bash
# Run all RSpec tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/controllers/api/imports_controller_spec.rb
bundle exec rspec spec/services/restaurant_import_service_spec.rb

# Run with verbose output
bundle exec rspec --format documentation

# Run specific test patterns
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
```

### Code Quality

```bash
# Run RuboCop for code style
bundle exec rubocop

# Run Brakeman for security analysis
bundle exec brakeman
```

## Docker Support

The application includes Docker support for production deployment:

```bash
# Build the Docker image
docker build -t popmenu .

# Run with Docker
docker run -p 3000:3000 -e RAILS_MASTER_KEY=<your-master-key> popmenu
```

## Database Schema

The application uses the following models:
- **Restaurant**: Stores restaurant information
- **Menu**: Stores menu information (belongs to restaurant)
- **MenuItem**: Stores menu item information
- **MenuMenuItem**: Join table for menu-item associations

## Import Data Format

See `IMPORT_INSTRUCTIONS.md` for detailed information about the JSON format and import options.

## Troubleshooting

### Common Issues

1. **Database connection errors**: Ensure PostgreSQL is running and credentials in `config/database.yml` are correct
2. **Bundle install issues**: Make sure you're using Ruby 3.4.5
3. **Import errors**: Check the JSON format matches the expected structure

### Logs

Check the Rails logs for detailed error information:
```bash
tail -f log/development.log
```