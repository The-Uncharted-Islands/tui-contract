// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TUI is ERC20, Ownable {
    mapping(address => bool) public _blackList;

    uint256 public constant MAX_SUPPLY = 4000000000 * 10 ** 18;

    event SetBlackList(address indexed account, bool enable);

    error ZeroAddressCannotBlacklisted();

    constructor() ERC20("TheUnchartedIslands", "TUI") {
    }

    function mintTo(address owner) public onlyOwner{
        _mint(owner, MAX_SUPPLY);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            !_blackList[from] && !_blackList[to],
            "transfer from/to blacklist address"
        );
        super._transfer(from, to, amount);
    }

    function setBlackList(address account, bool enable) public onlyOwner {
        if (account == address(0)) revert ZeroAddressCannotBlacklisted();

        if (_blackList[account] == enable) return;
        _blackList[account] = enable;
        emit SetBlackList(account, enable);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blackList[account];
    }
}
