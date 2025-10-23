# Fungible Asset Vesting

A Move module for creating time-based linear token vesting schedules on Aptos using the Fungible Asset standard.

## Overview

This module enables creators to lock tokens that are gradually released to recipients over time. Tokens vest linearly at a constant rate, and recipients can claim their vested tokens at any time.

## How It Works

1. **Create Vesting**: Creator sets up a schedule with start time, duration, release rate, token type, and recipient
2. **Deposit**: Total amount (`release_rate � duration`) is transferred to a vesting object
3. **Claim**: Recipient claims vested tokens based on elapsed time since start

## Usage

### Create Vesting Schedule

```move
public entry fun create_vesting_entry(
    creator: &signer,
    start_timestamp: u64,      // Unix timestamp (must be future)
    duration: u64,             // Duration in seconds
    release_rate: u64,         // Tokens per second
    vesting_token: Object<Metadata>,
    recipient: address
)
```

**Example**: Vest 10,000 tokens over 1,000 seconds

- `start_timestamp`: 200
- `duration`: 1000
- `release_rate`: 10
- Total: 10,000 tokens

### Claim Vested Tokens

```move
public entry fun claim_vested(claimer: &signer, vesting_obj: Object<Vesting>)
```

### Query Details

```move
#[view]
public fun get_vesting_detail(vesting_obj: Object<Vesting>): (u64, u64, u64, address, address, u64)
```

Returns: start_timestamp, duration, release_rate, token_address, recipient, already_claimed

## Development

### Testing

```bash
./sh_scripts/test.sh
```

### Building & Deployment

```bash
./sh_scripts/deploy.sh
```

## Features

- Linear vesting with configurable schedules
- Multiple partial claims supported
- Object-based secure token custody
- Overflow protection on all calculations
- Event emissions for tracking
- Comprehensive test coverage

## Security

- Only recipients can claim tokens
- Start time must be in future
- Overflow checks on all arithmetic
- Non-zero validation on parameters

## Use Cases

Team token vesting, investor lock-ups, contributor rewards, grant distributions, time-based compensation
