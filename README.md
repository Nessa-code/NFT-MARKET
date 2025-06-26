# NFT-MARKET

A decentralized NFT marketplace for trading digital assets on the Stacks blockchain.

## Overview

NFT-MARKET provides a secure and efficient platform for listing, buying, and selling NFTs with built-in fee collection and marketplace statistics.

## Features

- **NFT Listings**: Create listings with custom pricing and duration
- **Direct Trading**: Buy NFTs directly with STX payments
- **Marketplace Fees**: Configurable fee structure for platform sustainability
- **Listing Management**: Update prices or cancel listings
- **Sales History**: Track all marketplace transactions
- **Statistics**: Real-time marketplace volume and activity data

## Contract Functions

### Public Functions

- `create-listing(nft-contract, token-id, price, duration)` - List an NFT for sale
- `update-listing(listing-id, new-price)` - Update listing price
- `cancel-listing(listing-id)` - Cancel an active listing
- `buy-nft(listing-id)` - Purchase a listed NFT
- `set-marketplace-fee(new-fee)` - Admin function to update fees
- `withdraw-fees()` - Admin function to collect marketplace fees

### Read-Only Functions

- `get-listing(listing-id)` - Get listing details and status
- `get-marketplace-fee()` - Get current marketplace fee percentage
- `get-marketplace-stats()` - Get volume, sales, and listing statistics

## Usage

### For Sellers
1. Call `create-listing` with your NFT details and desired price
2. Optionally update price using `update-listing`
3. Cancel listing anytime with `cancel-listing`

### For Buyers
1. Browse active listings using `get-listing`
2. Call `buy-nft` with sufficient STX to purchase
3. NFT ownership transfers automatically upon successful purchase

## Fee Structure

- Default marketplace fee: 2.5%
- Fees are automatically deducted from sale proceeds
- Sellers receive the remainder after fee deduction
- Maximum fee cap: 10%

## Security

- Only listing owners can update or cancel their listings
- Automatic expiry prevents stale listings
- Payment verification ensures sufficient funds
- Owner-only administrative functions