// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract GoController is Ownable {
    struct TokenInfo {
        address creator;
        bool isMonitored;
        uint256 totalTransfers;
        uint256 totalBurns;
        uint256 totalMints;
    }

    mapping(address => TokenInfo) public monitoredTokens;
    
    event TokenAdded(address indexed token, address indexed creator);
    event TokenActivityLogged(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount,
        string activityType,
        uint256 timestamp
    );

    error TokenAlreadyMonitored();
    error TokenNotMonitored();
    error InvalidAddress();

    function addToken(address tokenAddress) external {
        if(tokenAddress == address(0)) revert InvalidAddress();
        if(monitoredTokens[tokenAddress].isMonitored) revert TokenAlreadyMonitored();
        
        monitoredTokens[tokenAddress] = TokenInfo({
            creator: msg.sender,
            isMonitored: true,
            totalTransfers: 0,
            totalBurns: 0,
            totalMints: 0
        });
        
        emit TokenAdded(tokenAddress, msg.sender);
    }

    function logActivity(
        address token,
        address from,
        address to,
        uint256 amount,
        string calldata activityType
    ) external {
        if(!monitoredTokens[token].isMonitored) revert TokenNotMonitored();
        
        TokenInfo storage tokenInfo = monitoredTokens[token];
        
        if(keccak256(bytes(activityType)) == keccak256(bytes("transfer"))) {
            tokenInfo.totalTransfers++;
        } else if(keccak256(bytes(activityType)) == keccak256(bytes("burn"))) {
            tokenInfo.totalBurns++;
        } else if(keccak256(bytes(activityType)) == keccak256(bytes("mint"))) {
            tokenInfo.totalMints++;
        }
        
        emit TokenActivityLogged(
            token,
            from,
            to,
            amount,
            activityType,
            block.timestamp
        );
    }

    function getTokenStats(address token) external view returns (
        uint256 transfers,
        uint256 burns,
        uint256 mints
    ) {
        TokenInfo memory info = monitoredTokens[token];
        return (info.totalTransfers, info.totalBurns, info.totalMints);
    }
}