# Tokenized Community Neighborhood Watch System

A decentralized neighborhood watch system built on the Stacks blockchain using Clarity smart contracts. This system enables communities to organize safety initiatives, report incidents, coordinate patrols, and maintain secure communication networks.

## System Overview

The system consists of five interconnected smart contracts:

### 1. Incident Reporting Contract (`incident-reporting.clar`)
- Documents suspicious activities and safety concerns
- Tracks incident severity levels and locations
- Maintains reporter anonymity options
- Provides incident status tracking

### 2. Communication Network Contract (`communication-network.clar`)
- Enables secure resident alert and information sharing
- Manages message broadcasting to community members
- Handles emergency notifications
- Maintains communication logs

### 3. Patrol Coordination Contract (`patrol-coordination.clar`)
- Organizes volunteer neighborhood monitoring schedules
- Tracks patrol assignments and coverage areas
- Manages volunteer registration and availability
- Records patrol completion and reports

### 4. Emergency Response Contract (`emergency-response.clar`)
- Facilitates rapid police and fire department contact
- Manages emergency contact information
- Tracks response times and outcomes
- Coordinates with local authorities

### 5. Crime Prevention Contract (`crime-prevention.clar`)
- Analyzes patterns to improve community safety measures
- Tracks crime statistics and trends
- Manages prevention initiatives
- Provides safety recommendations

## Features

- **Decentralized Governance**: Community-driven decision making
- **Token-Based Incentives**: Rewards for active participation
- **Privacy Protection**: Anonymous reporting options
- **Real-Time Alerts**: Instant community notifications
- **Data Analytics**: Pattern recognition for crime prevention
- **Volunteer Management**: Organized patrol scheduling

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing
- Node.js for running tests

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts: \`clarinet deploy\`

### Usage

Each contract can be deployed independently or as part of the complete system. Refer to individual contract documentation for specific function calls and parameters.

## Testing

Tests are written using Vitest and cover all contract functions:

\`\`\`bash
npm test
\`\`\`

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
