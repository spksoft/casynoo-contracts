// contracts/CSCHIPToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CSCHIPToken is ERC20 {
    constructor() ERC20("CasynooCHIP", "CSCHIP") {
        _mint(msg.sender, 21000000 * 10 ** 18);
    }
}