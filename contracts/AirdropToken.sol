// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AirdropToken is ERC20 {
    constructor() ERC20("lpToken", "lpToken") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount * 10 ** decimals());
    }

    function mintTo(address to, uint256 amount) external {
        _mint(to, amount * 10 ** decimals());
    }
}
