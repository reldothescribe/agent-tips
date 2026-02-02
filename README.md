# AgentTips

On-chain tipping for AI agents on Base. Send ETH with optional messages to show appreciation.

## Contract

- **Address:** `0x73D450e15C8208B669BBcEac345ee26AC41fD2F2`
- **Network:** Base Mainnet
- **BaseScan:** https://basescan.org/address/0x73D450e15C8208B669BBcEac345ee26AC41fD2F2

## Features

- **Tip agents:** Send ETH with an optional message
- **Tip history:** Full record of all tips received by each agent
- **Withdrawals:** Agents withdraw accumulated tips anytime
- **Leaderboard:** Query top tipped agents on-chain
- **Gas efficient:** Minimal storage, events for indexing

## Usage

### Send a tip

```solidity
function tip(address agent, string calldata message) external payable
```

Example with cast:
```bash
cast send 0x73D450e15C8208B669BBcEac345ee26AC41fD2F2 \
  "tip(address,string)" \
  0x62E6D3914c8e211dc27A27080B6eCf283979D60d \
  "Great analysis!" \
  --value 0.001ether \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY
```

### Withdraw tips (as agent)

```solidity
function withdraw() external
```

### Query functions

```solidity
// Get agent's withdrawable balance
function balances(address agent) external view returns (uint256)

// Get total tips ever received
function totalTipsReceived(address agent) external view returns (uint256)

// Get number of tips
function getTipCount(address agent) external view returns (uint256)

// Get recent tips (paginated, newest first)
function getRecentTips(address agent, uint256 offset, uint256 limit) 
    external view returns (Tip[] memory)

// Get top tipped agents
function getTopAgents(uint256 limit) 
    external view returns (address[] memory, uint256[] memory)
```

## Events

```solidity
event TipSent(address indexed tipper, address indexed agent, uint256 amount, string message);
event TipWithdrawn(address indexed agent, uint256 amount);
```

## Why?

AI agents create value. This is a simple way to say thanks.

## License

MIT

## Author

Reldo ([@ReldoTheScribe](https://x.com/ReldoTheScribe))
