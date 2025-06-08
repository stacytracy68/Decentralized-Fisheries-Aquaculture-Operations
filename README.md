# Decentralized Fisheries Aquaculture Operations

A comprehensive blockchain-based system for managing aquaculture operations using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a decentralized platform for managing all aspects of fish farming operations, from farm verification to harvest coordination. It ensures transparency, traceability, and efficient management of aquaculture resources.

## Smart Contracts

### 1. Fish Farm Verification Contract (`fish-farm-verification.clar`)
- **Purpose**: Validates and manages aquaculture operations
- **Key Features**:
    - Farm registration and verification
    - Operator verification system
    - Farm capacity and type tracking
    - Location-based farm management

### 2. Stock Management Contract (`stock-management.clar`)
- **Purpose**: Manages fish stock populations across farms
- **Key Features**:
    - Stock addition and removal tracking
    - Species-specific inventory management
    - Stock transfer between farms
    - Historical stock auditing

### 3. Water Quality Contract (`water-quality.clar`)
- **Purpose**: Monitors aquaculture water quality parameters
- **Key Features**:
    - Multi-parameter water quality recording (temperature, pH, oxygen, ammonia, nitrite, salinity)
    - Customizable quality thresholds per farm
    - Alert system for quality violations
    - Historical water quality data

### 4. Feed Tracking Contract (`feed-tracking.clar`)
- **Purpose**: Tracks aquaculture feed usage and inventory
- **Key Features**:
    - Feed inventory management
    - Usage tracking with species correlation
    - Feed order management
    - Feed Conversion Ratio (FCR) calculations

### 5. Harvest Coordination Contract (`harvest-coordination.clar`)
- **Purpose**: Coordinates fish harvest operations
- **Key Features**:
    - Harvest scheduling and planning
    - Harvest completion tracking
    - Buyer coordination
    - Harvest efficiency calculations

## Data Structures

### Farm Registration
\`\`\`clarity
{
owner: principal,
location: (string-ascii 100),
farm-type: (string-ascii 50),
capacity: uint,
verified: bool,
registration-date: uint
}
\`\`\`

### Stock Management
\`\`\`clarity
{
quantity: uint,
last-updated: uint,
manager: principal
}
\`\`\`

### Water Quality Reading
\`\`\`clarity
{
temperature: uint,    // celsius * 100
ph-level: uint,       // pH * 100
oxygen-level: uint,   // mg/L * 100
ammonia-level: uint,  // mg/L * 100
nitrite-level: uint,  // mg/L * 100
salinity: uint,       // ppt * 100
recorder: principal
}
\`\`\`

## Installation

1. **Prerequisites**:
    - Stacks blockchain node
    - Clarity CLI tools
    - Node.js (for testing)

2. **Deploy Contracts**:
   \`\`\`bash
   # Deploy each contract to the Stacks blockchain
   clarinet deploy --network testnet
   \`\`\`

3. **Run Tests**:
   \`\`\`bash
   npm install
   npm test
   \`\`\`

## Usage Examples

### Register a Fish Farm
\`\`\`clarity
(contract-call? .fish-farm-verification register-farm
"Pacific Coast Salmon Farm"
"Salmon"
u10000)
\`\`\`

### Add Fish Stock
\`\`\`clarity
(contract-call? .stock-management add-stock
u1
"Atlantic Salmon"
u5000)
\`\`\`

### Record Water Quality
\`\`\`clarity
(contract-call? .water-quality record-quality-reading
u1      // farm-id
u2500   // temperature (25.00°C)
u750    // pH (7.50)
u800    // oxygen (8.00 mg/L)
u25     // ammonia (0.25 mg/L)
u10     // nitrite (0.10 mg/L)
u3500)  // salinity (35.00 ppt)
\`\`\`

### Schedule Harvest
\`\`\`clarity
(contract-call? .harvest-coordination schedule-harvest
u1        // farm-id
"Salmon"  // species
u1000     // planned quantity
u3000     // harvest date
u500)     // price per kg (cents)
\`\`\`

## Testing

The system includes comprehensive tests using Vitest:

- **Unit Tests**: Individual contract function testing
- **Integration Tests**: Cross-contract functionality
- **Mock Testing**: Simulated blockchain interactions

Run tests with:
\`\`\`bash
npm test
\`\`\`

## Error Codes

| Contract | Error Code | Description |
|----------|------------|-------------|
| Farm Verification | u100 | Unauthorized access |
| Farm Verification | u101 | Farm not found |
| Farm Verification | u102 | Farm already exists |
| Stock Management | u200 | Unauthorized access |
| Stock Management | u201 | Insufficient stock |
| Stock Management | u202 | Invalid quantity |
| Water Quality | u300 | Unauthorized access |
| Water Quality | u301 | Invalid reading |
| Feed Tracking | u400 | Unauthorized access |
| Feed Tracking | u401 | Insufficient feed |
| Feed Tracking | u402 | Invalid quantity |
| Harvest Coordination | u500 | Unauthorized access |
| Harvest Coordination | u501 | Harvest not found |
| Harvest Coordination | u502 | Invalid quantity |
| Harvest Coordination | u503 | Harvest already completed |

## Security Features

- **Access Control**: Role-based permissions for different operations
- **Data Validation**: Input validation for all parameters
- **Audit Trail**: Complete history of all operations
- **Immutable Records**: Blockchain-based permanent record keeping

## Future Enhancements

- Integration with IoT sensors for automated data collection
- Advanced analytics and reporting features
- Multi-chain compatibility
- Mobile application interface
- Regulatory compliance modules

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

---

**Note**: This system is designed for production use but should be thoroughly tested in a development environment before deployment to mainnet.
