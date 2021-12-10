// contracts/HiLow.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CSCHIPToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HiLowGame is Ownable {
    uint256 public multiplier = 2;
    uint256 randNonce = 0;
    CSCHIPToken csCHIPToken;

    event EndGame(address winner, uint256 betSize);

    constructor(address tokenAddress) {
        csCHIPToken = CSCHIPToken(tokenAddress);
    }

    function play(bool isHigher, uint256 betSize) public returns (address rWinner, uint256 rBetSize) {
        uint256 balanceOfPlayer = csCHIPToken.balanceOf(msg.sender);
        require(balanceOfPlayer >= betSize, "You don't have enough CSCHIPs");
        uint256 balaceOfPool = csCHIPToken.balanceOf(address(this));
        require(balaceOfPool >= betSize, "Pool doesn't have enough CSCHIPs");
        
        uint256 random = _randMod(10, balanceOfPlayer + balaceOfPool + betSize);
        bool isPlayerWin = isHigher ? random >= 5 : random <= 4;
        bool sent = false;
        address winner;
        if (isPlayerWin) {
            sent = csCHIPToken.transfer(msg.sender, betSize);
            winner = msg.sender;
        } else {
            sent = csCHIPToken.transferFrom(msg.sender, address(this), betSize);
            winner = address(this);
        }
        require(sent, "Failed to transfer CSCHIPs");
        emit EndGame(winner, betSize);
        return (winner, betSize);
    }

    function getRewardPool() public view returns (uint256) {
        return csCHIPToken.balanceOf(msg.sender);
    }

    function setMultiplier(uint256 _multiplier) public onlyOwner {
        multiplier = _multiplier;
    }

    function setToken(address _tokenAddress) public onlyOwner {
        csCHIPToken = CSCHIPToken(_tokenAddress);
    }

    function _randMod(uint256 _modulus, uint256 seed) private returns (uint256) {
        // increase nonce
        randNonce = randNonce + (randNonce + seed) % 10000;
        if (randNonce > 10000000) {
            randNonce = (randNonce + seed) % 10000;
        }
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce, seed)
                )
            ) % _modulus;
    }
}
