# Restaurant Data Import Instructions

This document provides instructions on how to use the restaurant data import functionality.

## Overview

The import system allows you to import restaurant data from JSON files into the application. It supports:
- Multiple restaurants
- Multiple menus per restaurant
- Menu items with prices
- Both `menu_items` and `dishes` key variants
- Price normalization (handles strings, numbers, and currency formats)
- Duplicate handling (menu items can appear on multiple menus)
- Comprehensive logging and error handling

## JSON Format

The expected JSON format is:

```json
{
  "restaurants": [
    {
      "name": "Restaurant Name",
      "menus": [
        {
          "name": "Menu Name",
          "menu_items": [
            {
              "name": "Item Name",
              "price": 9.99
            }
          ]
        }
      ]
    }
  ]
}
```

### Alternative Format (dishes instead of menu_items)

```json
{
  "restaurants": [
    {
      "name": "Restaurant Name",
      "menus": [
        {
          "name": "Menu Name",
          "dishes": [
            {
              "name": "Item Name",
              "price": 9.99
            }
          ]
        }
      ]
    }
  ]
}
```

## Import Methods

### 1. HTTP API Endpoint

**Endpoint:** `POST /api/imports`

**Content-Type:** `application/json`

#### Method 1: Raw JSON in request body
```bash
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d '{"restaurants": [{"name": "Test Restaurant", "menus": [{"name": "lunch", "menu_items": [{"name": "Burger", "price": 9.99}]}]}]}'
```

#### Method 2: JSON data parameter
```bash
curl -X POST http://localhost:3000/api/imports \
  -H "Content-Type: application/json" \
  -d '{"json_data": "{\"restaurants\": [{\"name\": \"Test Restaurant\", \"menus\": [{\"name\": \"lunch\", \"menu_items\": [{\"name\": \"Burger\", \"price\": 9.99}]}]}]}"}'
```

#### Method 3: File upload (multipart/form-data)
```bash
curl -X POST http://localhost:3000/api/imports \
  -F "file=@restaurant_data.json"
```

### 2. Rake Task (Command Line)

#### Import from file:
```bash
rails restaurants:import[path/to/restaurant_data.json]
```

#### Import sample data:
```bash
rails restaurants:import_sample
```

## Response Format

The import endpoint returns a JSON response with the following structure:

```json
{
  "success": true,
  "total_processed": 5,
  "success_count": 5,
  "error_count": 0,
  "logs": [
    {
      "level": "info",
      "message": "Created new restaurant: Test Restaurant",
      "timestamp": "2024-01-01T12:00:00.000Z"
    }
  ]
}
```

### Response Fields:
- `success`: Boolean indicating if the import was completely successful
- `total_processed`: Total number of items processed
- `success_count`: Number of successfully processed items
- `error_count`: Number of items that failed to process
- `logs`: Array of log entries with level, message, and timestamp

## Error Handling

The system handles various error scenarios:

1. **Invalid JSON format**: Returns 400 Bad Request
2. **Invalid JSON structure**: Returns 422 Unprocessable Entity
3. **Missing required fields**: Logs errors and continues processing
4. **Database errors**: Logs errors and continues processing
5. **Unexpected errors**: Returns 500 Internal Server Error

## Data Processing Rules

1. **Restaurant Names**: Must be unique. Existing restaurants are reused.
2. **Menu Names**: Must be unique per restaurant. Existing menus are reused.
3. **Menu Item Names**: Must be unique per restaurant. Existing items are updated with new prices.
4. **Price Normalization**: 
   - Numbers: Used as-is
   - Strings: Extracts numeric value (e.g., "$15.00" becomes 15.00)
   - Invalid prices: Logged as errors
5. **Menu Associations**: Menu items are associated with all specified menus

## Sample Data

The system includes sample data that matches the provided JSON structure:

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
    },
    {
      "name": "Casa del Poppo",
      "menus": [
        {
          "name": "lunch",
          "dishes": [
            {"name": "Chicken Wings", "price": 9.00},
            {"name": "Burger", "price": 9.00}
          ]
        },
        {
          "name": "dinner",
          "dishes": [
            {"name": "Mega \"Burger\"", "price": 22.00},
            {"name": "Lobster Mac & Cheese", "price": 31.00}
          ]
        }
      ]
    }
  ]
}
```

## Testing

Run the test suite to verify import functionality:

```bash
rails test
```

The test suite includes:
- Controller tests for HTTP endpoints
- Service tests for import logic
- Error handling tests
- Data validation tests

## Logging

All import operations are logged to:
1. **Application logs**: Standard Rails logging
2. **Response logs**: Included in API responses
3. **Console output**: For rake task operations

Log levels:
- `info`: Successful operations
- `error`: Failed operations and validation errors
