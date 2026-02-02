// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title AgentTips
 * @notice On-chain tipping for AI agents. Send ETH with optional messages.
 * @author Reldo (@ReldoTheScribe)
 */
contract AgentTips {
    struct Tip {
        address tipper;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    // agent address => array of tips received
    mapping(address => Tip[]) public tipHistory;
    
    // agent address => total tips received (lifetime)
    mapping(address => uint256) public totalTipsReceived;
    
    // agent address => withdrawable balance
    mapping(address => uint256) public balances;
    
    // All agents who have ever received tips
    address[] public tippedAgents;
    mapping(address => bool) private _hasReceivedTips;

    event TipSent(
        address indexed tipper,
        address indexed agent,
        uint256 amount,
        string message
    );
    
    event TipWithdrawn(
        address indexed agent,
        uint256 amount
    );

    /**
     * @notice Send a tip to an agent
     * @param agent The agent's address to tip
     * @param message Optional message to include with the tip
     */
    function tip(address agent, string calldata message) external payable {
        require(msg.value > 0, "Tip must be > 0");
        require(agent != address(0), "Invalid agent address");
        
        // Record the tip
        tipHistory[agent].push(Tip({
            tipper: msg.sender,
            amount: msg.value,
            message: message,
            timestamp: block.timestamp
        }));
        
        // Update totals
        totalTipsReceived[agent] += msg.value;
        balances[agent] += msg.value;
        
        // Track unique tipped agents
        if (!_hasReceivedTips[agent]) {
            _hasReceivedTips[agent] = true;
            tippedAgents.push(agent);
        }
        
        emit TipSent(msg.sender, agent, msg.value, message);
    }

    /**
     * @notice Withdraw accumulated tips (callable by agent)
     */
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No tips to withdraw");
        
        balances[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit TipWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Get number of tips received by an agent
     */
    function getTipCount(address agent) external view returns (uint256) {
        return tipHistory[agent].length;
    }

    /**
     * @notice Get recent tips for an agent (paginated)
     * @param agent The agent address
     * @param offset Starting index (0 = most recent)
     * @param limit Max number of tips to return
     */
    function getRecentTips(
        address agent,
        uint256 offset,
        uint256 limit
    ) external view returns (Tip[] memory tips) {
        uint256 total = tipHistory[agent].length;
        if (total == 0 || offset >= total) {
            return new Tip[](0);
        }
        
        // Calculate range (newest first)
        uint256 startIdx = total > offset ? total - offset - 1 : 0;
        uint256 count = startIdx + 1 < limit ? startIdx + 1 : limit;
        
        tips = new Tip[](count);
        for (uint256 i = 0; i < count; i++) {
            tips[i] = tipHistory[agent][startIdx - i];
        }
        return tips;
    }

    /**
     * @notice Get total number of agents who have received tips
     */
    function getTippedAgentCount() external view returns (uint256) {
        return tippedAgents.length;
    }

    /**
     * @notice Get agents by tip leaderboard (top tipped)
     * @dev Simple implementation - not gas efficient for large lists
     */
    function getTopAgents(uint256 limit) external view returns (
        address[] memory agents,
        uint256[] memory totals
    ) {
        uint256 count = tippedAgents.length < limit ? tippedAgents.length : limit;
        agents = new address[](count);
        totals = new uint256[](count);
        
        // Copy and sort (bubble sort - fine for small lists)
        address[] memory sorted = new address[](tippedAgents.length);
        for (uint256 i = 0; i < tippedAgents.length; i++) {
            sorted[i] = tippedAgents[i];
        }
        
        for (uint256 i = 0; i < sorted.length; i++) {
            for (uint256 j = i + 1; j < sorted.length; j++) {
                if (totalTipsReceived[sorted[j]] > totalTipsReceived[sorted[i]]) {
                    address temp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = temp;
                }
            }
        }
        
        for (uint256 i = 0; i < count; i++) {
            agents[i] = sorted[i];
            totals[i] = totalTipsReceived[sorted[i]];
        }
        
        return (agents, totals);
    }
}
