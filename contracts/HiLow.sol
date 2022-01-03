// contracts/HiLow.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CSCHIPToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HiLow is Ownable {
    bool private isTest = false;
    uint private randNonce = 0;
    uint private mockBlockDiff = 0;
    uint private mockBlockTime = 0;
    CSCHIPToken private csCHIPToken;

    event EndGame(address winner, uint betSize);

    constructor(address tokenAddress, bool _isTest) {
        csCHIPToken = CSCHIPToken(tokenAddress);
        isTest = _isTest;
        
    }

    function play(bool isHigher, uint betSize) public returns (address rWinner, uint rBetSize) {
        uint allowance = csCHIPToken.allowance(msg.sender, address(this));
        require(allowance >= betSize, "Check the token allowance");
        uint balaceOfPool = csCHIPToken.balanceOf(address(this));
        require(balaceOfPool >= betSize, "Pool doesn't have enough CSCHIPs");

        uint seed = allowance + balaceOfPool;
        uint random = _randMod(1, 10000, seed);
        bool isPlayerWin = _isPlayerWin(isHigher, random);
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

    function _isPlayerWin(bool playerPickHigher, uint randomValue) private pure returns (bool) {
        // Player pick: 0 = Lower, 1 = Higher
        // Result 0 = Lower, 1 = Higher
        if (playerPickHigher == true) {
            return randomValue > 5000 ? true : false;
        } else {
            return randomValue <= 5000 ? true : false;
        }
    }

    function _getAndSetRandomNonce(uint seed) private returns (uint) {
        randNonce = randNonce + (randNonce + seed) % 10000;
        if (randNonce > 100000000) {
            randNonce = (randNonce + seed) % 10000;
        }
        return randNonce;
    }

    function _randMod(uint from, uint to, uint seed) private view returns (uint) {
        return
            (uint(
                keccak256(
                    abi.encodePacked(_getBlockDifficulty(), _getBlockTimestamp(), msg.sender, seed)
                )
            ) % to) + from;
    }

    function _getBlockTimestamp() private view returns (uint) {
        return (isTest == true) ? mockBlockDiff : block.timestamp;
    }

    function _getBlockDifficulty() private view returns (uint) {
        return (isTest == true) ? mockBlockTime : block.difficulty;
    }

    function getRandNonce() public view returns (uint) {
        return randNonce;
    }

    function getIsTest() public view returns (bool) {
        return isTest;
    }

    function getPrizePoolBalance() public view returns (uint) {
        return csCHIPToken.balanceOf(address(this));
    }

    function transferFromPricePoolToOwner(uint amount) onlyOwner public returns (bool) {
        return csCHIPToken.transfer(msg.sender, amount);
    }

    function setMockBlockDiff(uint diff) onlyOwner public {
        mockBlockDiff = diff;
    }

    function setMockBlockTime(uint time) onlyOwner public {
        mockBlockTime = time;
    }
        
}
