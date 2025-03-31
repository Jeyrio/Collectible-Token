# Collectible Token

A flexible and feature-rich NFT implementation built with Clarity 6.0 for the Stacks blockchain.

## Overview

Collectible Token is a robust smart contract that enables the creation, management, and trading of non-fungible tokens (NFTs) on the Stacks blockchain. 
Built with Clarity 6.0, this contract offers advanced features including batch minting, token destruction, and URI updates.

## Features

- **Single and Batch Minting**: Create individual tokens or mint multiple collectibles in a single transaction.
- **Secure Ownership**: Strong ownership validation ensures only authorized users can transfer or modify tokens.
- **Metadata Management**: Each token has a URI linking to its metadata, which can be updated by the token owner.
- **Token Destruction**: Owners can permanently destroy their tokens.
- **Batch Operations**: Efficient querying of token information in batches.
- **Admin Controls**: Contract administrator privileges for minting and system management.

## Getting Started

### Prerequisites

- [Clarity VSCode Extension](https://marketplace.visualstudio.com/items?itemName=blockstack.clarity) for development.
- [Clarinet](https://github.com/hirosystems/clarinet) for testing and deployment.
- A Stacks wallet for interacting with the deployed contract.

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/collectible-token.git
   cd collectible-token
   ```

2. Install dependencies:
   ```bash
   clarinet requirements
   ```

3. Test the contract:
   ```bash
   clarinet test
   ```

### Deployment

Deploy to the Stacks testnet or mainnet:

```bash
clarinet deploy --testnet # or --mainnet for production
```

## Usage

### Minting a Collectible

```clarity
(contract-call? .collectible-token mint "https://example.com/metadata/1")
```

### Batch Minting

```clarity
(contract-call? .collectible-token batch-mint (list "https://example.com/metadata/1" "https://example.com/metadata/2"))
```

### Transferring a Collectible

```clarity
(contract-call? .collectible-token transfer u1 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Updating Metadata URI

```clarity
(contract-call? .collectible-token update-collectible-uri u1 "https://example.com/updated-metadata/1")
```

### Destroying a Collectible

```clarity
(contract-call? .collectible-token destroy u1)
```

### Retrieving Collectible Data

```clarity
(contract-call? .collectible-token get-collectible-uri u1)
(contract-call? .collectible-token get-owner u1)
(contract-call? .collectible-token is-destroyed u1)
```

## Contract Structure

- `collectible-token.clar`: The main contract file containing all functionality.
- Constants define error codes and configuration settings.
- Maps store token URIs and tracking information.
- Public functions provide the external API.
- Private helper functions handle internal logic.

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Admin only operation |
| u101 | Not the collectible owner |
| u102 | Collectible already exists |
| u103 | Collectible not found |
| u104 | Invalid collectible URI |
| u105 | Destroy operation failed |
| u106 | Collectible already destroyed |
| u107 | Not authorized to update collectible |
| u108 | Invalid batch size |
| u109 | Batch mint failed |

## Security Considerations

- The contract implements strict ownership checks.
- Admin functions are restricted to the contract deployer.
- Token transfers require sender and receiver validation.
- URI validation prevents empty or oversized metadata references.

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by NFT standards across multiple blockchain ecosystems.
- Built with Clarity 6.0 features for enhanced functionality.
