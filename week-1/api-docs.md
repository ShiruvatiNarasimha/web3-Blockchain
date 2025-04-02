# API Documentation

## Overview

This API provides access to various financial data endpoints from the Financial Modeling Prep service. The API is exposed at `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp` and requires a `path` and `symbol` as query parameters. Some endpoints also accept optional parameters such as `period`, `from`, `to`, and `limit`.

## Authentication

All API endpoints require authentication using a Bearer token. You must include a valid ID token in the Authorization header of each request.

### Request Headers

- Authorization: Bearer {ID_TOKEN}

Requests without a valid ID token will receive a 401 Unauthorized response.

## ValueEQ Endpoints

### 1. Screener

- **Description**: Filters companies based on specified criteria. Supports Natural Language Query (NLQ) for filter generation and allows specifying a view to select specific fields.
- **Path**: `/screener`
- **Method**: POST
- **Required Parameters**:
  - `filters` (array of filter objects with `name`, `function`, and `value`)
  - `NLQ` (string, optional): A natural language query that can be parsed into filters.
  - `view` (array of strings, optional): Specifies which fields to return in the response.
- **Pagination**:
  - Responses are paginated with a maximum of 15 elements per page.
  - Use the `continuationToken` query parameter to retrieve subsequent pages.
  - For deals pagination, use the `dealsContinuationToken` parameter.
- **Example**:
  ```json
  POST https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/screener
  {
    "filters": [
      {
        "name": "beta",
        "function": "Greater than",
        "value": 1.0
      },
      {
        "name": "exchangeShortName",
        "function": "Is one of",
        "value": ["NASDAQ", "NYSE"]
      },
      {
        "name": "isActivelyTrading",
        "function": "Equal to",
        "value": true
      },
      {
        "name": "description",
        "function": "Contains",
        "value": "smartphones"
      },
      {
        "name": "mktCap",
        "function": "Between",
        "value": [1000000000000, 5000000000000]
      }
    ],
    "NLQ": "Show me companies with a beta greater than 1.0 and listed on NASDAQ or NYSE",
    "view": ["symbol", "companyName", "beta", "mktCap"]
  }
  ```
- **Returns**: A paginated list of companies matching the filter criteria. Each company object includes properties such as `symbol`, `beta`, `mktCap`, `exchangeShortName`, `industry`, `description`, `sector`, `country`, and `region`. The response also includes a `continuationToken` for fetching the next page of results.

#### Deal Screening Support

The screener now supports filtering both companies and deals in a single query.

- **Deal-specific fields**:

  - `dealDate`: Date when the deal occurred
  - `dealStatus`: Current status of the deal
  - `stake`: Percentage of ownership acquired
  - `targetCompany`: Company being acquired
  - `acquiringCompany`: Company making the acquisition
  - `dealValue`: Monetary value of the deal
  - `source`: Source of the deal information

- **Shared fields** (can be used to filter both companies and deals):

  - `country`: Country of the company or deal
  - `region`: Geographic region
  - `sector`: Business sector
  - `industry`: Specific industry
  - `description`: Text description
  - `revenue`: Revenue figure
  - `ebitda`: Earnings before interest, taxes, depreciation, and amortization
  - `evSales`: Enterprise value to sales ratio
  - `evEbitda`: Enterprise value to EBITDA ratio

- **Filter Logic**:

  - The API automatically determines whether a filter should be applied to companies, deals, or both
  - Deal-specific filters are only applied to the deals collection
  - Company-specific filters are only applied to the companies collection
  - Shared field filters are applied to both collections

- **Response Format**:

  ```json
  {
    "filteredItems": [...],  // Original companies response (backwards compatibility)
    "filters": [...],        // Original filters (backwards compatibility)
    "continuationToken": "token-for-companies", // (backwards compatibility)
    "totalCount": 150,       // Total count for companies (backwards compatibility)

    "companies": {
      "items": [...],        // Array of company matches
      "continuationToken": "token-for-companies",
      "totalCount": 150,     // Total count of matching companies
      "filters": [...]       // Filters applied to companies
    },
    "deals": {
      "items": [...],        // Array of deal matches
      "continuationToken": "token-for-deals",
      "totalCount": 25,      // Total count of matching deals
      "filters": [...]       // Filters applied to deals
    }
  }
  ```

- **Backwards Compatibility**:

  - The original response format is preserved (`filteredItems`, `filters`, `continuationToken`, `totalCount`)
  - New clients should use the structured `companies` and `deals` objects
  - To paginate through deals, use the returned `deals.continuationToken` as `dealsContinuationToken` in subsequent requests

- **Supported Filter Functions**:
  - `Equal to`: Exact match (case-insensitive for strings)
  - `Not equal to`: Excludes exact matches
  - `Greater than`: Numeric comparison
  - `Greater than or equal to`: Numeric comparison
  - `Less than`: Numeric comparison
  - `Less than or equal`: Numeric comparison
  - `Between`: Range of values (inclusive)
  - `Is one of`: Matches any value in an array
  - `Is not one of`: Excludes values in an array
  - `Contains`: Substring match (case-insensitive)

### 2. Companies

- **Description**: Retrieves detailed information about multiple companies.
- **Path**: `/companies`
- **Method**: GET
- **Required Parameters**:
  - `symbols` (query parameter): A comma-separated list of company symbols.
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/companies?symbols=AAPL,GOOGL
  ```
- **Returns**: An array of detailed information for each specified company, including all screener and metric points, as well as historical and forward calculations.

#### Company Analysis

- **Description**: Generates a comprehensive analysis report for a specific company.
- **Path**: `/companies/analysis`
- **Method**: GET
- **Required Parameters**:
  - `symbol` (query parameter): The stock symbol of the company to analyze.
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/companies/analysis?symbol=AAPL
  ```
- **Returns**: A detailed analysis report covering:
  - Products and Services
  - Business Model
  - Customer Profiles
  - Market Segments
  - M&A Activity
  - Market Position
  - Key Competitors
  - ESG Performance
  - Risk Analysis
  - Keywords for comparable company screening

### 3. Watchlists

#### Create Watchlist

- **Description**: Creates a new watchlist for the authenticated user.
- **Path**: `/watchlist`
- **Method**: POST
- **Required Parameters**:
  - `name`: Name of the watchlist
  - `symbols` (optional): Array of stock symbols
  - `dealIds` (optional): Array of deal IDs
  - `views` (optional): Array of fields to track
- **Example**:
  ```json
  POST https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist
  {
    "name": "Tech Stocks",
    "symbols": ["AAPL", "GOOGL", "MSFT"],
    "dealIds": ["deal-1", "deal-2"],
    "views": ["symbol", "companyName", "price", "beta", "mktCap"]
  }
  ```

#### Get All Watchlists

- **Description**: Retrieves all watchlists for the authenticated user.
- **Path**: `/watchlist`
- **Method**: GET
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist
  ```

#### Get Single Watchlist

- **Description**: Retrieves a specific watchlist with latest company and deal data and metrics.
- **Path**: `/watchlist/:id`
- **Method**: GET
- **Returns**: Watchlist with "latest" snapshot containing companies, deals, and metrics
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist/123e4567-e89b-12d3-a456-426614174000
  ```
- **Response Format**:
  ```json
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "tenantId": "tenant-id",
    "userId": "user-id",
    "name": "Tech Stocks",
    "symbols": ["AAPL", "GOOGL", "MSFT"],
    "dealIds": ["deal-1", "deal-2"],
    "views": ["symbol", "companyName", "price", "beta", "mktCap"],
    "createdAt": "2023-01-01T00:00:00.000Z",
    "snapshots": {
      "latest": {
        "companies": [...],         // Array of company objects
        "deals": [...],             // Array of deal objects
        "metrics": {
          "companies": {            // Metrics for companies
            "beta": {
              "avg": 1.2,
              "median": 1.1,
              "firstQuartile": 0.9,
              "thirdQuartile": 1.4
            },
            // Other metrics...
          },
          "deals": {                // Metrics for deals
            "dealValue": {
              "avg": 500000000,
              "median": 450000000,
              "firstQuartile": 300000000,
              "thirdQuartile": 700000000
            },
            // Other metrics...
          }
        }
      },
      // Other snapshots...
    }
  }
  ```
- **Backwards Compatibility**:
  - For watchlists with only companies (no deals), the response follows the legacy format:
  ```json
  {
    // Watchlist properties...
    "snapshots": {
      "latest": {
        "companies": [...],         // Array of company objects
        "metrics": {                // Directly contains company metrics
          "beta": {
            "avg": 1.2,
            "median": 1.1,
            "firstQuartile": 0.9,
            "thirdQuartile": 1.4
          },
          // Other metrics...
        }
      }
    }
  }
  ```

#### Create Watchlist Snapshot

- **Description**: Creates a snapshot of current company and deal data for a watchlist.
- **Path**: `/watchlist/:id/snapshot`
- **Method**: POST
- **Example**:
  ```
  POST https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist/123e4567-e89b-12d3-a456-426614174000/snapshot
  ```
- **Returns**: The updated watchlist with the new snapshot
- **Snapshot Structure**:
  - Snapshots are stored with timestamps as keys
  - Each snapshot contains companies, deals (if any), and metrics
  - For backwards compatibility, watchlists without deals use the legacy metrics structure

#### Export Watchlist

- **Description**: Exports watchlist data to Excel format, including all snapshots.
- **Path**: `/watchlist/:id/export`
- **Method**: GET
- **Returns**: Excel file containing watchlist data with separate sheets for each snapshot.
  - Includes separate sheets for companies and deals where applicable
  - Includes metrics in dedicated sheets
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist/123e4567-e89b-12d3-a456-426614174000/export
  ```

#### Update Watchlist

- **Description**: Updates an existing watchlist's name, symbols, dealIds, or views.
- **Path**: `/watchlist/:id`
- **Method**: PUT
- **Required Parameters**:
  - At least one of:
    - `name`: New name for the watchlist
    - `symbols`: Updated array of stock symbols
    - `dealIds`: Updated array of deal IDs
    - `views`: Updated array of fields to track
- **Example**:
  ```json
  PUT https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist/123e4567-e89b-12d3-a456-426614174000
  {
    "name": "Updated Tech Stocks",
    "symbols": ["AAPL", "GOOGL", "MSFT", "META"],
    "dealIds": ["deal-1", "deal-3"],
    "views": ["symbol", "companyName", "price", "beta"]
  }
  ```

#### Delete Watchlist

- **Description**: Permanently deletes a watchlist.
- **Path**: `/watchlist/:id`
- **Method**: DELETE
- **Returns**: Status 204 on successful deletion
- **Example**:
  ```
  DELETE https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/watchlist/123e4567-e89b-12d3-a456-426614174000
  ```

### 4. Managing Deals

The system automatically processes deals from an Excel file called "M&A Template.xlsx" when the application starts. As a memeber of the repository, you can update this file directly through GitHub to add new deals without needing developer assistance.

#### Adding New Deals Through GitHub

1. **Access the GitHub Repository**:

   - Navigate to the ValueEQ-Web-Backend repository on GitHub
   - Make sure you are logged in with an account that has write access to the repository

2. **Locate the Deals Template File**:

   - Browse to the `data` folder
   - Find the file named `M&A Template.xlsx`

3. **Update the File**:

   - Click on the file to view it
   - Click the "..." menu button at the top-right of the file view
   - Select "Delete file" to remove the current version
   - Confirm the deletion by committing directly to the main branch
   - Navigate back to the `data` folder
   - Click "Add file" > "Upload files"
   - Drag and drop or choose your updated Excel file with the same name "M&A Template.xlsx"
   - Add a commit message like "Update M&A deals data - [current date]"
   - Select "Commit directly to the main branch"
   - Click "Commit changes"

4. **Trigger Deployment**:

   - After committing the file, navigate to the "Actions" tab in the repository
   - Find the most recent workflow run that was automatically triggered by your commit
   - If no workflow was automatically triggered, you can manually run the deployment workflow:
     - Click on the "Workflows" section on the left
     - Find the deployment workflow (likely named something like "Deploy to Azure")
     - Click "Run workflow" > "Run workflow" on the main branch

5. **Verify Processing**:
   - The application will restart as part of the deployment
   - When it starts, it will automatically process the updated Excel file
   - New deals will be added to the database and will appear in the application

**Important Notes**:

- Do not change the column names or structure of the Excel file
- All deals should be added in the first sheet of the Excel, starting from the second row
- To promote efficiency, delete the existing deals in the template (which have already been processed) and only keep the new ones
- The system will skip any deals that already exist in the database (based on Deal Date and Target Company)
- Numeric values should be entered as numbers without currency symbols
- Dates should be in a standard Excel date format

## User Endpoints

#### Check Subscription

- **Description**: Checks if the authenticated user has an active Stripe subscription.
- **Path**: `/user/check-subscription`
- **Method**: GET
- **Returns**: JSON object containing subscription status and details
  - `hasActiveSubscription`: Boolean indicating if user has an active subscription
  - `subscriptionDetails`: (Only present if hasActiveSubscription is true)
    - `subscriptionId`: The Stripe subscription ID
    - `status`: Current subscription status
    - `currentPeriodEnd`: Date when the current subscription period ends
- **Example Request**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user/check-subscription
  ```
- **Example Response**:
  ```json
  {
    "hasActiveSubscription": true,
    "subscriptionDetails": {
      "subscriptionId": "sub_1234567890",
      "status": "active",
      "currentPeriodEnd": "2024-12-31T23:59:59.000Z"
    }
  }
  ```
  or
  ```json
  {
    "hasActiveSubscription": false,
    "subscriptionDetails": null
  }
  ```

#### Sign Up

- **Description**: Creates a new user account and tenant organization.
- **Path**: `/user/sign-up`
- **Method**: POST
- **Required Parameters**:
  - `email`: User's email address
  - `firstName`: User's first name
  - `lastName`: User's last name
  - `plan`: Subscription plan (must be "Professional" or "Enterprise")
- **Returns**: New user and tenant information
- **Example Request**:
  ```json
  POST https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user/sign-up
  {
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "plan": "Professional"
  }
  ```
- **Example Response**:
  ```json
  {
    "message": "User and tenant created successfully",
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "tenantId": "tenant-id",
      "role": "Admin",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "isActive": true
    },
    "tenant": {
      "id": "tenant-id",
      "name": "John Doe's Organization",
      "plan": "Professional",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "createdBy": "user-id",
      "isActive": true,
      "userLimit": 1
    }
  }
  ```

#### Get Current User

- **Description**: Retrieves information about the currently authenticated user.
- **Path**: `/user`
- **Method**: GET
- **Returns**: User profile, tenant information, and subscription status
- **Example Request**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user
  ```
- **Example Response**:
  ```json
  {
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "tenantId": "tenant-id",
      "role": "Admin",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "isActive": true
    },
    "tenant": {
      "id": "tenant-id",
      "name": "John Doe's Organization",
      "plan": "Professional",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "createdBy": "user-id",
      "isActive": true,
      "userLimit": 1
    },
    "hasActiveSubscription": true
  }
  ```

#### Get All Users (Admin Only)

- **Description**: Retrieves all active users within the admin's tenant.
- **Path**: `/user/users`
- **Method**: GET
- **Access**: Restricted to users with Admin role
- **Returns**: Array of user objects within the tenant
- **Example Request**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user/users
  ```
- **Example Response**:
  ```json
  [
    {
      "id": "user-id-1",
      "email": "admin@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "tenantId": "tenant-id",
      "role": "Admin",
      "createdAt": "2023-01-01T00:00:00.000Z",
      "isActive": true
    },
    {
      "id": "user-id-2",
      "email": "user@example.com",
      "firstName": "Jane",
      "lastName": "Smith",
      "tenantId": "tenant-id",
      "role": "User",
      "createdAt": "2023-01-02T00:00:00.000Z",
      "isActive": true
    }
  ]
  ```

#### Add User (Admin Only)

- **Description**: Adds a new user to the admin's tenant.
- **Path**: `/user/add`
- **Method**: POST
- **Access**: Restricted to users with Admin role
- **Required Parameters**:
  - `email`: New user's email address
  - `firstName`: New user's first name
  - `lastName`: New user's last name
  - `password`: Password for the new user's account
  - `role` (optional): User's role (defaults to "User", can be "Admin" or "User")
- **Returns**: The newly created user
- **Example Request**:
  ```json
  POST https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user/add
  {
    "email": "newuser@example.com",
    "firstName": "Jane",
    "lastName": "Smith",
    "password": "securePassword123",
    "role": "User"
  }
  ```
- **Example Response**:
  ```json
  {
    "message": "User created successfully",
    "user": {
      "id": "new-user-id",
      "email": "newuser@example.com",
      "firstName": "Jane",
      "lastName": "Smith",
      "tenantId": "tenant-id",
      "role": "User",
      "createdAt": "2023-01-15T00:00:00.000Z",
      "isActive": true
    }
  }
  ```

#### Delete User (Admin Only)

- **Description**: Soft-deletes a user by making them inactive.
- **Path**: `/user/users/:userId`
- **Method**: DELETE
- **Access**: Restricted to users with Admin role
- **URL Parameters**:
  - `userId`: ID of the user to delete
- **Returns**: Success message
- **Example Request**:
  ```
  DELETE https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/user/users/user-id-to-delete
  ```
- **Example Response**:
  ```json
  {
    "message": "User deleted successfully"
  }
  ```

## Direct FMP Endpoints

### 3. Profile

- **Description**: Fetches the profile of a company.
- **Path**: `/profile`
- **Required Parameters**: `symbol`
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=profile&symbol=AAPL `

### 4. Stock Peers

- **Description**: Retrieves peer companies for a given stock.
- **Path**: `/stock_peers`
- **Required Parameters**: `symbol`
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=stock_peers&symbol=AAPL `

### 5. Score

- **Description**: Provides a score for a given stock.
- **Path**: `/score`
- **Required Parameters**: `symbol`
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=score&symbol=AAPL `

### 6. Historical Price Full - Stock Dividend

- **Description**: Fetches historical stock dividend data.
- **Path**: `/historical-price-full/stock_dividend`
- **Required Parameters**: `symbol`
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=historical-price-full/stock_dividend&symbol=AAPL `

### 7. Income Statement

- **Description**: Retrieves the income statement.
- **Path**: `/income-statement`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `period` (values: `annual`, `quarter`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=income-statement&symbol=AAPL&period=annual `

### 8. Balance Sheet Statement

- **Description**: Fetches the balance sheet statement.
- **Path**: `/balance-sheet-statement`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `period` (values: `annual`, `quarter`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=balance-sheet-statement&symbol=AAPL&period=quarter `

### 9. Cash Flow Statement

- **Description**: Provides the cash flow statement.
- **Path**: `/cash-flow-statement`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `period` (values: `annual`, `quarter`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=cash-flow-statement&symbol=AAPL&period=annual `

### 10. Income Statement Growth

- **Description**: Retrieves income statement growth data.
- **Path**: `/income-statement-growth`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `period` (values: `annual`, `quarter`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=income-statement-growth&symbol=AAPL&period=quarter `

### 11. Analyst Estimates

- **Description**: Provides analyst estimates.
- **Path**: `/analyst-estimates`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `period` (values: `annual`, `quarter`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=analyst-estimates&symbol=AAPL&period=annual `

### 12. Historical Price Full

- **Description**: Fetches full historical price data.
- **Path**: `/historical-price-full`
- **Required Parameters**: `symbol`
- **Optional Parameters**: `from`, `to` (date format: `YYYY-MM-DD`), `limit` (integer)
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=historical-price-full&symbol=AAPL&from=2023-01-01&to=2023-12-31 `

### 13. Stock List

- **Description**: Retrieves a list of stocks. Only returns stocks with "type": "stock".
- **Path**: `/stock/list`
- **Example**: `https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=stock/list `

### 14. Historical Price EOD Light

- **Description**: Fetches end-of-day historical price data with optional date range.
- **Path**: `/historical-price-eod/light`
- **Required Parameters**:
  - `symbol`: The stock symbol for which to fetch historical data.
- **Optional Parameters**:
  - `from`: Start date for the historical data (format: `YYYY-MM-DD`).
  - `to`: End date for the historical data (format: `YYYY-MM-DD`).
- **Example**:
  ```
  GET https://wa-valueeq-backend-weu-001-enhcg0h7ave2dmak.westeurope-01.azurewebsites.net/api/fmp?path=historical-price-eod/light&symbol=AAPL&from=2023-01-01&to=2023-12-31
  ```
- **Returns**: An array of historical price data for the specified symbol, optionally filtered by the provided date range.

## Notes

- Ensure that the `symbol` parameter is always provided where required.
- Optional parameters should be used as needed based on the endpoint requirements.

This documentation provides a comprehensive guide to using the API and constructing requests for each endpoint.
